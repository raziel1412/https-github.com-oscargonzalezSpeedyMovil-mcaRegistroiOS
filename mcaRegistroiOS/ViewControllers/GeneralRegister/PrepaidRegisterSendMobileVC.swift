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
import mcaAddServiceiOS

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
    var lineOfBussines: TypeLineOfBussines = TypeLineOfBussines.Fixed
    
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
        
        if previousView == TypeRegisterView.AddPrepaid || lineOfBussines.rawValue == "3"{
            if conf?.pinMessageRules?.showMaskedPhoneNumber ?? false {
                let codigoPais = (mcaManagerSession.getGeneralConfig()?.country?.phoneCountryCode ?? "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "+", with: "")
                self.mobilePhone = String(format: "%@%@", codigoPais, self.mobilePhone!)
                lblCelNum.text = mobilePhone?.maskPhone()
            }
        }
        
        if previousView == TypeRegisterView.RegisterPrepaid{
            if conf?.pinMessageRules?.showMaskedPhoneNumber ?? false {
                let codigoPais = (mcaManagerSession.getGeneralConfig()?.country?.phoneCountryCode ?? "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "+", with: "")
                self.mobilePhone = String(format: "%@%@", codigoPais, self.mobilePhone!)
                lblCelNum.text  = self.mobilePhone
            }
        }
        
        lblCelNum.font = UIFont(name: RobotoFontName.RobotoBold.rawValue, size: CGFloat(17.0))
        lblCelNum.textColor = institutionalColors.claroBlueColor
        
        if previousView == TypeRegisterView.AddPrepaid{
            AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewServicioPrepago(viewName: "Mis servicios|Agregar prepago|Paso 2|Enviar codigo verificacion", type: "2", detenido: false)
        }else{
            AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 3|Enviar codigo verificacion", type:3, detenido: false,typeLoB: "1")
        }
        
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
        
        if previousView == TypeRegisterView.AddPrepaid{
            AnalyticsInteractionSingleton.sharedInstance.ADBTrackCustomLink(viewName: "Mis servicios|Agregar prepago|Paso 2|Enviar codigo verificacion:Enviar")
        }else{
            AnalyticsInteractionSingleton.sharedInstance.ADBTrackCustomLink(viewName: "Registro|Paso 3|Enviar codigo verificacion:Enviar")
        }
        
        let req = ValidateNumberRequest();
        req.validateNumber?.claroNumber = self.mobilePhone;
        req.validateNumber?.userProfileId = self.rut;
        
        req.validateNumber?.lineOfBusiness = lineOfBussines.rawValue
        
        mcaManagerServer.executeValidateNumber(params: req,
                                                     onSuccess: { (result) in
                                                        if self.previousView == TypeRegisterView.AddPrepaid{
                                                            let onAcceptEvent = {
                                                                if let container = self.so_containerViewController {
                                                                    container.isSideViewControllerPresented = false;
                                                                }
                                                                
                                                                let prepaid2 = AddPrepaidStep2VC()
                                                                prepaid2.phoneUser = self.mobilePhone!
                                                                self.navigationController?.pushViewController(prepaid2, animated: true)
                                                                AnalyticsInteractionSingleton.sharedInstance.ADBTrackCustomLink(viewName: "Mis servicios|Agregar prepago|Paso 3|Mensaje enviado:Cerrar")
                                                            }
                                                            
                                                            GeneralAlerts.showAcceptOnly(title: self.conf?.translations?.data?.generales?.done ?? "",
                                                                                         text: self.conf?.translations?.data?.generales?.smsSend ?? "",
                                                                                         icon: .IconoAlertaSMS,
                                                                                         acceptTitle: self.conf!.translations!.data!.generales!.closeBtn!,
                                                                                         acceptBtnColor: institutionalColors.claroBlueColor,
                                                                                         onAcceptEvent: onAcceptEvent)
                                                        }else{
                                                            let typeLoB = self.lineOfBussines == TypeLineOfBussines.Prepaid ? "1" : self.lineOfBussines == TypeLineOfBussines.Postpaid ? "2" : ""
                                                            
                                                            AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 4|Mensaje enviado", type: 4, detenido: false, typeLoB: typeLoB)
                                                            
                                                             let onAcceptEvent = {
                                                                if let container = self.so_containerViewController {
                                                                    container.isSideViewControllerPresented = false;
                                                                }
                                                                
                                                                if self.previousView == TypeRegisterView.RegisterPrepaid {
                                                                    AnalyticsInteractionSingleton.sharedInstance.initTimer()
                                                                    let smsCode = PrepaidRegisterStep4VC();
                                                                    smsCode.previousView = TypeRegisterView.RegisterPrepaid
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
                                                                AnalyticsInteractionSingleton.sharedInstance.ADBTrackCustomLink(viewName: "Registro|Paso 4|Mensaje enviado:Cerrar")
                                                            }
                                                           
                                                            GeneralAlerts.showAcceptOnly(title: self.conf?.translations?.data?.generales?.pinAlertTitle ?? "",
                                                                                         text: self.conf?.translations?.data?.generales?.pinAlert ?? "",
                                                                                         icon: .IconoAlertaSMS, acceptTitle: self.conf?.translations?.data?.generales?.acceptBtn ?? "", acceptBtnColor: institutionalColors.claroBlueColor, onAcceptEvent: onAcceptEvent)
                                                        }
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
