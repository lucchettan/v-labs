//
//  RunningFromAppStore.swift
//  Home Control
//
//  Created by Robbert Brandsma on 27/10/2020.
//  Copyright © 2020 OWOW. All rights reserved.
//

import UIKit

extension UIApplication {
    /// Returns `true` if the app is downloaded from the app store.
    @available(iOSApplicationExtension, unavailable)
    public static let isDownloadedFromTheAppStore: Bool = {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else {
            return false
        }
        
        return !receiptURL.path.contains("sandboxReceipt")
    }()
}
