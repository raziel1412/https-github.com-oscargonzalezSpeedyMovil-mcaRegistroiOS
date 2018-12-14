//
//  PrepaidRegisterSendMobileVC.swift
//  MiClaro
//
//  Created by Jorge Isai Garcia Reyes on 30/08/18.
//  Copyright © 2018 am. All rights reserved.
//

import UIKit
import Cartography
import mcaManageriOS
import mcaUtilsiOS

enum TypeRegisterView {
    case Prepaid
    case Register
}

class PrepaidRegisterSendMobileVC: UIViewController{
    
    var doLoginWhenFinish :((_ doAutomaticLogin: Bool) -> Void) = {_ in }
    
    @IBOutlet weak var lblTilteView: UILabel!
    @IBOutlet weak var lblDesView: UILabel!
    @IBOutlet weak var lblCelNum: UILabel!
    //var navType = navType.register
    var previousView = TypeRegisterView.Register
    
    /// Botón de siguiente
    var nextButton: RedBorderWhiteBackgroundButton!
    
    private var conf : GeneralConfig?
    
    /// Clase que almacena el request para preguntas de seguridad
    private var personal : ValidatePersonalVerificationQuestionRequest?
    /// Cadena que almacena el RUT
    private var rut : String?
    /// Cadena que almacena el mobile Phone
    private var mobilePhone : String?
    
    /// Line of business
    var lineOfBussines: TypeLineOfBussines = TypeLineOfBussines.Fijo
    
    /// Line of business
    var reqNum: ValidateNumberRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        conf = mcaManagerSession.getGeneralConfig()
        
        self.initWith(navigationType: .IconBack, headerTitle: conf?.translations?.data?.registro?.header ?? "")
        
        lblTilteView.text = (conf?.translations?.data?.registro?.title) ?? ""
        lblTilteView.textColor = institutionalColors.claroBlackColor
        lblTilteView.textColor = institutionalColors.claroBlackColor
        if UIScreen.main.bounds.width == 320{
            lblTilteView.font = UIFont(name: RobotoFontName.RobotoRegular.rawValue, size: CGFloat(16))
        }else{
            lblTilteView.font = UIFont(name: RobotoFontName.RobotoRegular.rawValue, size: CGFloat(20))
        }
       
        lblDesView.text = (conf?.translations?.data?.registro?.confirmPrepaid) ?? ""
        lblDesView.textColor = institutionalColors.claroTextColor
        lblDesView.font = UIFont(name: RobotoFontName.RobotoRegular.rawValue, size: CGFloat(16))
        lblDesView.numberOfLines = 0
        lblDesView.textColor = institutionalColors.claroTextColor
        
        let completePhone = String(format: "+%@", mobilePhone ?? "")
        lblCelNum.text = completePhone
        
        if previousView == TypeRegisterView.Prepaid {
            if conf?.pinMessageRules?.showMaskedPhoneNumber ?? false {
                let codigoPais = (mcaManagerSession.getGeneralConfig()?.country?.phoneCountryCode ?? "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "+", with: "")
                self.mobilePhone = String(format: "%@%@", codigoPais, self.mobilePhone!)
                lblCelNum.text = mobilePhone?.maskPhone()
            }
        }
        
        if lineOfBussines.rawValue == "3"{
            if conf?.pinMessageRules?.showMaskedPhoneNumber ?? false {
                let codigoPais = (mcaManagerSession.getGeneralConfig()?.country?.phoneCountryCode ?? "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "+", with: "")
                self.mobilePhone = String(format: "%@%@", codigoPais, self.mobilePhone!)
                lblCelNum.text = mobilePhone?.maskPhone()
            }
        }
    
        lblCelNum.font = UIFont(name: RobotoFontName.RobotoBold.rawValue, size: CGFloat(17.0))
        lblCelNum.textColor = institutionalColors.claroBlueColor
        
        let continuar = conf?.translations?.data?.generales?.nextBtn
        nextButton = RedBorderWhiteBackgroundButton(textButton: continuar != nil ? continuar! : "")
        nextButton.addTarget(self, action: #selector(btnsendSMS), for: UIControlEvents.touchUpInside)
        self.view.addSubview(nextButton)
        setupConstraints()
    }
    
    func setupConstraints() {
        constrain(self.view, lblDesView, lblCelNum, nextButton) { (view, desc, phone, next) in
            next.top == phone.bottom + 50.0
            next.leading == view.leading + 31.0
            next.trailing == view.trailing - 32.0
            next.height == 40
        }
    }
    
    func btnsendSMS() {
        
        AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 2|Enviar codigo verificacion", type:2, detenido: false)
        AnalyticsInteractionSingleton.sharedInstance.ADBTrackCustomLink(viewName: "Registro|Paso 2|Enviar codigo verificacion:Enviar")
        
        let req = ValidateNumberRequest();
        req.validateNumber?.claroNumber = self.mobilePhone;
        req.validateNumber?.userProfileId = self.rut;
        
        req.validateNumber?.lineOfBusiness = lineOfBussines.rawValue
        
        mcaManagerServer.executeValidateNumber(params: req,
                                                     onSuccess: { (result) in
                                                        
                                                        let onAcceptEvent = {
                                                            if let container = self.so_containerViewController {
                                                                container.isSideViewControllerPresented = false;
                                                            }
                                                            
                                                            if self.previousView == TypeRegisterView.Prepaid {
                                                                let smsCode = PrepaidRegisterStep4VC();
                                                                smsCode.setValues(number: self.mobilePhone!, rut: self.rut!, Lob: self.lineOfBussines, req: req, personalQ: nil)
                                                                smsCode.doLoginWhenFinish = self.doLoginWhenFinish
                                                                self.navigationController?.pushViewController(smsCode, animated: true)
                                                            } else {
                                                                let bySMS = CodeBySmsVC();
                                                                bySMS.doLoginWhenFinish = self.doLoginWhenFinish
                                                                bySMS.lineOfBusinnes = self.lineOfBussines
                                                                bySMS.rutUser = self.rut!
                                                                bySMS.phoneUser = self.mobilePhone!
                                                                bySMS.setPersonalQuestions(r: self.personal);
                                                                bySMS.setValidateNumber(r: req);
                                                                self.navigationController?.pushViewController(bySMS, animated: true)
                                                            }
                                                            if self.lineOfBussines.rawValue == "3"{
                                                                let smsCode = PrepaidRegisterStep4VC()
                                                                smsCode.doLoginWhenFinish = self.doLoginWhenFinish
                                                                smsCode.setValues(number: self.mobilePhone!, rut: self.rut!, Lob: self.lineOfBussines, req: req, personalQ: nil)
                                                                self.navigationController?.pushViewController(smsCode, animated: true)
                                                            }
                                                            AnalyticsInteractionSingleton.sharedInstance.ADBTrackCustomLink(viewName: "Registro|Paso 3|Mensaje enviado:Cerrar")
                                                        }
                                                        
                                                        GeneralAlerts.showAcceptOnly(title: self.conf?.translations?.data?.generales?.pinAlertTitle ?? "",
                                                                                     text: self.conf?.translations?.data?.generales?.pinAlert ?? "",
                                                                                     icon: .IconoAlertaSMS, acceptTitle: self.conf?.translations?.data?.generales?.acceptBtn ?? "", acceptBtnColor: institutionalColors.claroBlueColor, onAcceptEvent: onAcceptEvent)
                                                        
                                                        AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 3|Mensaje enviado",type:3, detenido: false)
                                                        
        },
                                                     onFailure: { (result, myError) in
                                                        GeneralAlerts.showAcceptOnly(text: result?.validateNumberResponse?.acknowledgementDescription ?? "", icon: AlertIconType.IconoAlertaError, onAcceptEvent: {})

        });
    }
    
    /// Función que permite asignar la cadena del RUT a la variable
    func setRUT(r : String?) {
        self.rut = r;
    }
    /// Función que permite asignar las preguntas de verificación
    func setPersonalQuestions(r : ValidatePersonalVerificationQuestionRequest?) {
        self.personal = r;
    }
    
    /// Función que permite asignar el validateNumer
    func setReqNum(r : ValidateNumberRequest?) {
        self.reqNum = r;
    }
    
    /// Función que permite asignar el telefono del usuario
    func setMobilePhone(r : String?) {
        self.mobilePhone = r;
    }
    
    /// Alerta de insuficiencia de memoria
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
