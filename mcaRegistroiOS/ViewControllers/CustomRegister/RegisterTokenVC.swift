//
//  RegisterTokenVC.swift
//  mcaRegistroiOS
//
//  Created by Ricardo Rodriguez De Los Santos on 3/29/19.
//  Copyright © 2019 Speedy Movil. All rights reserved.
//

import UIKit
import Cartography
import mcaUtilsiOS
import mcaManageriOS
import mcaManageriOS

class RegisterTokenVC: UIViewController {


    /// Variable ValidateNumberRequest
    private var reqNum : ValidateNumberRequest?
    /// Variable ValidatePersonalVerificationQuestionRequest
    private var personal : ValidatePersonalVerificationQuestionRequest?
    /// Constante archivo de configuración general
    private let conf = mcaManagerSession.getGeneralConfig()
    /// Botón siguiente
    var nextButton: RedBorderWhiteBackgroundButton!
    
    /// Contenedor de la vista de código
    var lblToken: UITextField!
    
    /// Etiqueta linkeable
    var linkeableLabel: LinkableLabel!
    //For identifier if is Prepago(2) or Postpago(1)
    /// Variable que almacena el TypeLineOfBussines
    var lineOfBusinnes: TypeLineOfBussines?

    /// Variable que almacena el phoneUser
    var phoneUser: String = ""
    
    var insertCodeLabel: UILabel!
    
    var headerView : UIHeaderForm3 = UIHeaderForm3(frame: .zero)
    
    
    func setupElements() {
        self.initWith(navigationType:.IconBack, headerTitle: conf?.translations?.data?.registro?.header ?? "")
        self.view.backgroundColor = institutionalColors.claroWhiteColor
        headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200)
        headerView.setupElements(imageName: "ico_seccion_registro",
                                 title: "Código de seguridad",
                                 subTitle: "Para continuar con el registro hemos enviado un código de seguridad a: \(phoneUser)")
        headerView.colorTextSetupElements(colorTitle: institutionalColors.claroBlackColor, colorSubtitle: institutionalColors.claroLightGrayColor)
        self.view.addSubview(headerView)
        
        insertCodeLabel =  UILabel()
        insertCodeLabel.text = "Ingresa tu codigo"
        insertCodeLabel.textAlignment = .center
        self.view.addSubview(insertCodeLabel)
        
        lblToken = UITextField()
        lblToken.frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 100, height: 40)
        lblToken.setBottomBorder()
        lblToken.textAlignment = .center
        
        self.view.addSubview(lblToken)
        
        linkeableLabel = LinkableLabel()
        let tap = UITapGestureRecognizer(target: self, action: #selector(resendCode(sender:)));
        linkeableLabel.addGestureRecognizer(tap)
        linkeableLabel.showText(text: conf?.translations?.data?.generales?.resendPin != nil ? "No recibiste el código, da <b>clic a quí</b> para enviarlo." : "" )
        linkeableLabel.textAlignment = .center
        self.view.addSubview(linkeableLabel)
        
        nextButton = RedBorderWhiteBackgroundButton(textButton: conf?.translations?.data?.generales?.validateBtn != nil ? conf!.translations!.data!.generales!.validateBtn! : "")
        nextButton.addTarget(self, action: #selector(validateCode), for: UIControlEvents.touchUpInside)
        
        self.view.addSubview(nextButton)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        
        constrain(self.view, headerView, lblToken, insertCodeLabel) { (view, header, container, codeLabel) in
            header.top == view.top
            header.leading == view.leading
            header.trailing == view.trailing
            header.height == view.height * 0.35
            
            codeLabel.top == header.bottom
            codeLabel.leading == view.leading
            codeLabel.trailing == view.trailing
            codeLabel.height == view.height * 0.10
            
            
            container.top == codeLabel.bottom + 10.0
            container.centerX == view.centerX
            container.width == view.width * 0.11 * 5
            container.height == 40.0
            
            
            
        }
        
        constrain(self.view, lblToken, nextButton) { (view, container, button) in
            button.top == container.bottom + 30.0
            button.leading == view.leading + 31.0
            button.trailing == view.trailing - 32.0
            button.height == 40
        }
        
        constrain(self.view, nextButton, linkeableLabel) { (view, container, label) in
            
            label.top == container.bottom + 30.0
            label.leading == view.leading
            label.trailing == view.trailing
            label.height == 18.0
        }
        
        
        
    }
    
    
    /// Función encargada de cargar las vistas y variables
    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
    }
    override func viewWillAppear(_ animated: Bool) {
        AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 4|Ingresar codigo verificacion",type:4, detenido: false)
    }
    
    /// Touches began
    /// - parameter touches : Set<UITouch>
    /// - parameter event : UIEvent?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /// Alerta de insuficiencia de memoria
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Función encargada de enviar el código por SMS nuevamente
    /// - parameter sender : Any
    func resendCode(sender: Any) {

        let req = SetTokenRequest()
        if isNumber(){
            req.setToken?.mobileNumber = phoneUser.trimmingCharacters(in: CharacterSet.whitespaces)
            req.setToken?.userProfileId = ""
        }else{
            req.setToken?.mobileNumber = ""
            req.setToken?.userProfileId = phoneUser.trimmingCharacters(in: CharacterSet.whitespaces)
        }
        req.setToken?.channel = ""
        req.setToken?.consumerPreferredLanguage = ""
        req.setToken?.isDelegate = ""
        req.setToken?.token = "AppMovil-000000-a3e6-6abd-020a01aa32"
        req.setToken?.version = "2.2"
        req.setToken?.lineOfBusiness = "0"
        req.setToken?.ownerProfileId = ""
        req.setToken?.requestingUserId = ""
        req.setToken?.uUID = ""
        
        mcaManagerServer.executeSetToke(params: req, onSuccess: { (result) in
            GeneralAlerts.showAcceptOnly(title: "", text: "Se ha enviado el codigo nuevamente", icon: AlertIconType.IconoAlertaOK, onAcceptEvent: {})
        }) { (result, myError) in
            GeneralAlerts.showAcceptOnly(title: "", text: "No se puedo enviar el codigo intenta mas tarde", icon: AlertIconType.IconoAlertaError, onAcceptEvent: {})
        }
        
    }
    
    func validateCode(){
        if !lblToken.text!.isEmpty {
            executeServiceValidateToken()
        }else{
            GeneralAlerts.showAcceptOnly(title: "", text: "Ingresa el token enviado", icon: AlertIconType.IconoAlertaError, onAcceptEvent: {})
        }
    }
    
    func executeServiceValidateToken(){
        
        let req = ValidateTokenRequest()
        if isNumber(){
            req.validateToken?.mobileNumber = phoneUser.trimmingCharacters(in: CharacterSet.whitespaces)
            req.validateToken?.userProfileId = ""
        }else{
            req.validateToken?.mobileNumber = ""
            req.validateToken?.userProfileId = phoneUser.trimmingCharacters(in: CharacterSet.whitespaces)
        }
        req.validateToken?.channel = ""
        req.validateToken?.consumerPreferredLanguage = ""
        req.validateToken?.isDelegate = ""
        req.validateToken?.token = lblToken.text!
        req.validateToken?.version = "2.2"
        req.validateToken?.lineOfBusiness = "0"
        req.validateToken?.ownerProfileId = ""
        req.validateToken?.requestingUserId = ""
        req.validateToken?.uUID = ""
        req.validateToken?.tokenSesion = "AppMovil-000000-a3e6-6abd-020a01aa32"
        
        mcaManagerServer.executeValidateToken(params: req, onSuccess: {(result) in
            
            let prepaid5 = CompleteRegisterVC()
            prepaid5.numberOrMail = self.phoneUser
            self.navigationController?.pushViewController(prepaid5, animated: true)
            
        }) { (result, myError) in
           GeneralAlerts.showAcceptOnly(title: "", text: myError.localizedDescription, icon: AlertIconType.IconoAlertaError, onAcceptEvent: {})
        }
    }
    
    func isNumber() -> Bool{
        if let _ = Int(phoneUser.trimmingCharacters(in: CharacterSet.whitespaces)){
            return true
        }
        return false
    }
}
