//
//  mcaRegisterManager.swift
//  mcaRegistroiOS
//
//  Created by Pilar del Rosario Prospero Zeferino on 12/12/18.
//  Copyright © 2018 Speedy Movil. All rights reserved.
//

import UIKit
import mcaManageriOS

public enum RegisterType {
    case General
    case Custom
}

public class mcaRegisterManager: NSObject {
    
    open class func launch(navController: UINavigationController?, typeRegister: RegisterType, doLoginWhenFinish: @escaping ((_ doAutomaticLogin: Bool) -> Void)) {
        
        let countryCode = mcaManagerSession.getCurrentCountry() ?? ""
        if countryCode == "CL"{
            if typeRegister == .General {
                let initialRegisterVC = PrepaidRegisterDataVC()
                initialRegisterVC.doLoginWhenFinish = doLoginWhenFinish
                navController?.pushViewController(initialRegisterVC, animated: true)
            } else if typeRegister == .Custom {
                //navController?.pushViewController(PrepaidRegisterStep1VC(), animated: true)
                let initialRegisterVC = PrepaidRegisterStep1VC()
                initialRegisterVC.doLoginWhenFinish = doLoginWhenFinish
                navController?.pushViewController(initialRegisterVC, animated: true)
            }
        }else{
            let initialRegisterVC = RegisterStep1VC()
            initialRegisterVC.doLoginWhenFinish = doLoginWhenFinish
            navController?.pushViewController(initialRegisterVC, animated: true)
        }
    }

}
