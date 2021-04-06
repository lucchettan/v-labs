import SwiftUI
import UIKit

/// A `NavigationLink` with support for custom transitions using the UIKit `UIViewControllerAnimatedTransitioning` protocol.
@available(iOS 13.0.0, *)
public struct AnimatedTransitioningNavigationLink<Label, Destination, PresentationTransition, DismissalTransition>: View where Label: View, Destination: View, PresentationTransition: UIViewControllerAnimatedTransitioning, DismissalTransition: UIViewControllerAnimatedTransitioning {
    
    // MARK: State
    
    private let destination: Destination
    private let label: Label
    
    /// The state that `isActive` is bound to when no external binding is used.
    @State private var isActiveState = false
    
    /// The `isActive` binding. We are unable to use `Binding` as a property wrapper here, because it needs to be an optional.
    private var isActiveBinding: Binding<Bool>?
    
    private var isActive: Bool {
        get { isActiveBinding?.wrappedValue ?? isActiveState }
        nonmutating set {
            isActiveBinding?.wrappedValue = newValue
            isActiveState = newValue
        }
    }
    
    private let presentationTransition: PresentationTransition
    private let dismissalTransition: DismissalTransition
    
    // MARK: Init
    
    /// NOTE: Variants of this `init` exist both without `presentationTransition` and without `dismissalTransition`.
    public init(destination: Destination, presentationTransition: PresentationTransition, dismissalTransition: DismissalTransition, isActive: Binding<Bool>? = nil, @ViewBuilder label: () -> Label) {
        self.destination = destination
        self.presentationTransition = presentationTransition
        self.dismissalTransition = dismissalTransition
        self.label = label()
        self.isActiveBinding = isActive
    }
    
    public var body: some View {
        Button(action: self.initiateTransition) {
            label
        }
        .background(coordinator)
    }
    
    private var coordinator: TransitionCoordinatorView {
        TransitionCoordinatorView(
            destination: destination,
            isActive: isActiveBinding ?? $isActiveState,
            presentationTransition: presentationTransition,
            dismissalTransition: dismissalTransition
        )
    }
    
    private func initiateTransition() {
        isActive = true
    }
}

@available(iOS 13.0.0, *)
extension AnimatedTransitioningNavigationLink where PresentationTransition == _NoTransition {
    public init(destination: Destination, dismissalTransition: DismissalTransition, isActive: Binding<Bool>? = nil, @ViewBuilder label: () -> Label) {
        self.init(destination: destination, presentationTransition: _NoTransition(), dismissalTransition: dismissalTransition, isActive: isActive, label: label)
    }
}

@available(iOS 13.0.0, *)
extension AnimatedTransitioningNavigationLink where DismissalTransition == _NoTransition {
    public init(destination: Destination, presentationTransition: PresentationTransition, isActive: Binding<Bool>? = nil, @ViewBuilder label: () -> Label) {
        self.init(destination: destination, presentationTransition: presentationTransition, dismissalTransition: _NoTransition(), isActive: isActive, label: label)
    }
}

@available(iOS 13.0.0, *)
public class _NoTransition: NSObject, UIViewControllerAnimatedTransitioning {
    fileprivate override init() {
        super.init()
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        preconditionFailure()
    }
}

// MARK: Coordinator (Source)

@available(iOS 13.0.0, *)
fileprivate extension AnimatedTransitioningNavigationLink {
    struct TransitionCoordinatorView: UIViewControllerRepresentable {
        typealias Context = UIViewControllerRepresentableContext<Self>
        
        var destination: Destination
        @Binding var isActive: Bool
        var presentationTransition: PresentationTransition
        var dismissalTransition: DismissalTransition
        
        func makeUIViewController(context: Context) -> TransitionCoordinatorViewController {
            TransitionCoordinatorViewController(
                destination: destination,
                presentationTransition: presentationTransition,
                dismissalTransition: dismissalTransition,
                isActive: _isActive
            )
        }
        
        func updateUIViewController(_ uiViewController: TransitionCoordinatorViewController, context: Context) {
            uiViewController.destination = destination
            uiViewController.presentationTransition = presentationTransition
            uiViewController.dismissalTransition = dismissalTransition
            uiViewController.isActive = self._isActive
            
            if isActive && !uiViewController.hasPushed && !uiViewController.waitingForDelayedPush {
                uiViewController.doPush()
            }
        }
    }
    
    class TransitionCoordinatorViewController: UIViewController, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
        
        var destination: Destination
        var presentationTransition: PresentationTransition
        var dismissalTransition: DismissalTransition
        var isActive: Binding<Bool>
        var hasPushed = false
        var waitingForDelayedPush = false
        
        init(destination: Destination, presentationTransition: PresentationTransition, dismissalTransition: DismissalTransition, isActive: Binding<Bool>) {
            self.destination = destination
            self.presentationTransition = presentationTransition
            self.dismissalTransition = dismissalTransition
            self.isActive = isActive
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) { nil }
        
        func doPush() {
            guard let navigationController = self.navigationController else {
                self.waitingForDelayedPush = true
                return
            }
            
            let hostingController = AnimatedTransitioningDestinationHostingController(
                rootView: destination.onDisappear { [weak self] in
                    // TODO: Need to know the difference between pop and normal disappear.
                    self?.isActive.wrappedValue = false
                    self?.hasPushed = false
                },
                coordinatorViewController: self
            )
            
            let originalDelegate = navigationController.delegate
            navigationController.delegate = self
            DispatchQueue.main.async {
                navigationController.delegate = originalDelegate
            }
            
            self.navigationController!.pushViewController(hostingController, animated: true)
            hasPushed = true
        }
        
        func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            if presentationTransition is _NoTransition {
                return nil
            }
            
            return presentationTransition
        }
        
        func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            if dismissalTransition is _NoTransition {
                return nil
            }
            
            return dismissalTransition
        }
        
        func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            switch operation {
            case .push:
                return animationController(forPresented: toVC, presenting: navigationController, source: fromVC)
            case .pop:
                return animationController(forDismissed: fromVC)
            default:
                return nil
            }
        }
        
        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            
            if waitingForDelayedPush {
                DispatchQueue.main.async {
                    self.waitingForDelayedPush = false
                    self.doPush()
                }
            }
        }
    }
    
    final class AnimatedTransitioningDestinationHostingController<Content: View>: UIHostingController<Content> {
        
        weak var coordinatorViewController: TransitionCoordinatorViewController?
        
        init(rootView: Content, coordinatorViewController: TransitionCoordinatorViewController) {
            super.init(rootView: rootView)
            self.coordinatorViewController = coordinatorViewController
        }
        
        required init?(coder aDecoder: NSCoder) { nil }
        
        override func willMove(toParent parent: UIViewController?) {
            super.willMove(toParent: parent)
            
            if parent == nil, let coordinatorViewController = self.coordinatorViewController, let navigationController = self.navigationController {
                let originalDelegate = navigationController.delegate
                navigationController.delegate = coordinatorViewController
                
                DispatchQueue.main.async {
                    navigationController.delegate = originalDelegate
                }
            }
        }
        
        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            
            if parent == nil {
                /// The view was popped
                coordinatorViewController?.isActive.wrappedValue = false
            }
        }
        
    }
}
