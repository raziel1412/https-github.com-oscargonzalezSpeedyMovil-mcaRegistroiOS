//
//  mcaRegisterManager.swift
//  mcaRegistroiOS
//
//  Created by Pilar del Rosario Prospero Zeferino on 12/12/18.
//  Copyright © 2018 Speedy Movil. All rights reserved.
//

import UIKit

public enum RegisterType {
    case General
    case Custom
}

public class mcaRegisterManager: NSObject {
    
    public class func launch(navController: UINavigationController?, typeRegister: RegisterType) {
        if typeRegister == .General {
             navController?.pushViewController(PrepaidRegisterDataVC(), animated: true)
        } else if typeRegister == .Custom {
            navController?.pushViewController(PrepaidRegisterStep1VC(), animated: true)
        }
    }

}
