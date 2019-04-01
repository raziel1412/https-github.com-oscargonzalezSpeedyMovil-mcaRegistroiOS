//
//  RegisterStep1VC.swift
//  mcaRegistroiOS
//
//  Created by Ricardo Rodriguez De Los Santos on 3/28/19.
//  Copyright © 2019 Speedy Movil. All rights reserved.
//

import Foundation
import Cartography
import SwiftValidator
import mcaUtilsiOS
import mcaManageriOS


class RegisterStep1VC: UIViewController, MobilePhoneNumberOnChangeDelegate, UITextFieldDelegate, ValidationDelegate {
    
    var doLoginWhenFinish :((_ doAutomaticLogin: Bool) -> Void) = {_ in }
    
    /// Constante que almacena la configuración
    let conf = mcaManagerSession.getGeneralConfig()
    private lazy var headerView : UIHeaderForm3 = UIHeaderForm3(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200))
    private var lblNumEmail : UITextFieldGroup = UITextFieldGroup(frame: .zero)
    private var termsConditions : TermsAndConditions = TermsAndConditions(frame: .zero)
    /// Botón para continuar
    var nextButton: RedBorderWhiteBackgroundButton!
    /// Objeto para validaciones
    private var validador : Validator?
    
    
    func setupElements() {
        self.view.backgroundColor = UIColor.white
        self.initWith(navigationType:.IconBack, headerTitle: conf?.translations?.data?.registro?.header ?? "")
        let scrollView : UIScrollView = UIScrollView(frame: .zero)
        let viewContent : UIView = UIView(frame: self.view.bounds)
        validador = Validator()
        
        let titleHeader =  "Crea tu cuenta Mi Claro"
        let subTitle =  "Disfruta de todos los servicios Claro en una sola cuenta."
        
        headerView.setupElements(imageName: "ico_seccion_registro", title: titleHeader, subTitle: subTitle)
        headerView.colorTextSetupElements(colorTitle: institutionalColors.claroBlackColor, colorSubtitle: institutionalColors.claroLightGrayColor)
        
        viewContent.addSubview(headerView)
        
        let text = "Número móvil o Correo Electrónico"
        let placeHolder = "Número móvil o Correo Electrónico"
        let imageIcon = "icon_rut_input"
        
        lblNumEmail.setupContent(imageName: imageIcon, text: text, placeHolder: placeHolder)
        //textGroup.changeFont(font: UIFont(name: RobotoFontName.RobotoBlack.rawValue, size: CGFloat(14.0))!)
        lblNumEmail.textField.delegate = self
        lblNumEmail.textField.keyboardType = .asciiCapable
        lblNumEmail.textField.autocorrectionType = .no
        lblNumEmail.textField.autocapitalizationType = .none
        validador?.registerField(lblNumEmail.textField, rules: [RequiredRule(message: "empty-fields".localized)])
        viewContent.addSubview(lblNumEmail)
        
        let parte1 = conf?.translations?.data?.newRegisterTexts?.newRegisterTyCFirst ?? "";
        let parte2 = conf?.translations?.data?.generales?.termsAndConditions ?? "";
        let parte3 = conf?.translations?.data?.newRegisterTexts?.newRegisterTyCFinal ?? "";
        
        
        termsConditions.setContent(String(format: "%@ <b>%@</b> %@", parte1, parte2, parte3), url: mcaManagerSession.getGeneralConfig()?.termsAndConditions?.url ?? "", title: mcaManagerSession.getGeneralConfig()?.translations?.data?.generales?.termsAndConditions ?? "", acceptTitle: mcaManagerSession.getGeneralConfig()?.translations?.data?.generales?.closeBtn ?? "", offlineAction: {
            mcaManagerSession.showOfflineMessage()
        })
        //        termsConditions.setupClickDelegate(target: self, action: #selector(self.lnkTerminos_OnClick(sender:)))
        termsConditions.checkBox.addTarget(self, action: #selector(self.chkValidate), for: UIControlEvents.touchUpInside)
        viewContent.addSubview(termsConditions)
        
        
        nextButton = RedBorderWhiteBackgroundButton(textButton: conf?.translations?.data?.generales?.nextBtn ?? "")
        nextButton.addTarget(self, action: #selector(nextStep), for: UIControlEvents.touchUpInside)
        nextButton.isEnabled = true
        self.nextButton?.isUserInteractionEnabled = false
        self.nextButton?.alpha = 0.5
        viewContent.addSubview(nextButton)
        scrollView.addSubview(viewContent)
        scrollView.frame = viewContent.bounds
        scrollView.contentSize = viewContent.bounds.size
        self.view.addSubview(scrollView)
        termsConditions.checkBox.addTarget(self, action: #selector(self.cmdValidar_OnClick), for: UIControlEvents.touchUpInside)
        setupConstraints(view: viewContent)
    }
    
    func cmdValidar_OnClick() {
        self.validador?.validate(self);
        AnalyticsInteractionSingleton.sharedInstance.ADBTrackCustomLink(viewName: "Registro|Paso 1|Ingresar datos:Continuar")
    }
    
    @objc func nextStep() {
        
        if lblNumEmail.isFirstResponder {
            lblNumEmail.resignFirstResponder();
        }
        
        if let text = lblNumEmail.textField.text, text.count > 0{
            if isNumber(){
                if !validateNumberClaro(){
                    GeneralAlerts.showAcceptOnly(title: "", text: "El formato del numero es incorrecto", icon: AlertIconType.IconoAlertaError, onAcceptEvent: {})
                }else{
                    self.executeServiceValidateNumber()
                }
            }else{
                if !text.trimmingCharacters(in: CharacterSet.whitespaces).isValidEmail(){
                    GeneralAlerts.showAcceptOnly(title: "", text: "El formato del correo electrónico es incorrecto", icon: AlertIconType.IconoAlertaError, onAcceptEvent: {})
                }else{
                    self.executeServiceSetToken()
                }
            }
        } else {
            // CAMPO VACIO
            if (lblNumEmail.textField.text?.isEmpty == true){
                let lbEmptyField = (conf?.translations?.data?.generales?.emptyField) ?? ""
                lblNumEmail.mandatoryInformation.displayView(customString: lbEmptyField)
                
                AnalyticsInteractionSingleton.sharedInstance.ADBTrackView(viewName: "Registro|Paso 1|Ingresar RUT|Detenido", detenido: true, mensaje: lbEmptyField)
            }
        }
    }
    
    @objc func chkValidate(){
        if lblNumEmail.textField.canResignFirstResponder {
            lblNumEmail.textField.resignFirstResponder()
        }
        if termsConditions.isChecked == true{
            self.nextButton?.isUserInteractionEnabled = true
            self.nextButton?.alpha = 1.0
        }else{
            self.nextButton?.isUserInteractionEnabled = false
            self.nextButton?.alpha = 0.5
        }
    }
    
    func setupConstraints(view: UIView) {
        constrain(view, headerView, lblNumEmail, termsConditions) { (view, header, group, box) in
            header.top == view.top
            header.leading == view.leading
            header.trailing == view.trailing
            header.height == view.height * 0.35
            
            group.top == header.bottom + 16.0
            group.leading == view.leading + 32.0
            group.trailing == view.trailing - 31.0
            group.height == 60.0
            
            box.top == group.bottom + 16.0
            box.leading == view.leading + 32.0
            box.trailing == view.trailing - 31.0
            box.height == 40.0
            
        }
        constrain(view, termsConditions, nextButton) { (view, box, button) in
            button.top == box.bottom + 24.0
            button.leading == view.leading + 32.0
            button.trailing == view.trailing - 31.0
            button.height == 40.0
        }
    }
    
    
    
    /// Función encargada de inicializar elementos de la vista e inicializar variables
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = institutionalColors.claroWhiteColor
        setupElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //meter codigo aqui
        AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewServicioPrepago(viewName: "Mis servicios|Agregar prepago|Paso 1|Ingresar numero movi", type: "1", detenido: false)
    }
    
    /// Función depreciada
    func MobilePhoneChangeData(texto: String) {
    }
    
    /// Función encargada de enviar a términos y condiciones
    func lnkTerminos_OnClick(sender: Any) {
        AnalyticsInteractionSingleton.sharedInstance.ADBTrackCustomLink(viewName: "Mis servicios|Agregar prepago|Paso 1|Ingresar numero movil:Terminos y condiciones")
        if false == mcaManagerSession.isNetworkConnected() {
            mcaManagerSession.showOfflineMessage()
            return;
        }
        let config = mcaManagerSession.getGeneralConfig()
        let genericWebViewInfo = GenericWebViewModel(headerTitle: config?.translations?.data?.generales?.termsAndConditions ?? "", serviceSelected: WebViewType.TermsAndConditions, loadUrl: config?.termsAndConditions?.url ?? "", buttonNavType: .IconBack, reloadUrlSuccess: config?.paidServices?.first?.recarga?.urlSuccess, paidUrlSucces: config?.paidServices?.first?.pago?.urlSuccess)
        self.navigationController?.pushViewController(GenericWebViewVC(info: genericWebViewInfo), animated: true)
        
    }
    
    /// Función para determinar cuando se toque cualquier elemento de la vista
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /// Alerta de insuficiencia de memoria
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Función que evalua si todo esta correcto y realiza la llamada al Servicio Web
    func validationSuccessful() {
        
        lblNumEmail.resignFirstResponder()
        
        if lblNumEmail.canResignFirstResponder {
            lblNumEmail.resignFirstResponder();
        }
        
        if lblNumEmail.textField.text == "" {
            GeneralAlerts.showAcceptOnly(text: "empty-fields".localized, icon: .IconoAlertaError, onAcceptEvent: {})
        }
    }
    /// Función encargada de notificar si existe algún tiempo
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        //clearCells()
        errors.forEach({ error in
            print(error)
            if let _ = error.1.field as? SimpleGrayTextField {
                print("an error")
            }
        })
    }
    
    func isNumber() -> Bool{
        if let _ = Int(lblNumEmail.textField.text!.trimmingCharacters(in: CharacterSet.whitespaces)){
            return true
        }
        return false
    }
    
    func validateNumberClaro() -> Bool{
        if lblNumEmail.textField.text!.trimmingCharacters(in: CharacterSet.whitespaces).count != 8{
            return false
        }
        return true
    }
    
    func executeServiceValidateNumber(){
        if false == mcaManagerSession.isNetworkConnected() {
            return
        }
        let req = ValidateNumberRequest()
        req.validateNumber?.claroNumber = lblNumEmail.textField.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        req.validateNumber?.channel = ""
        req.validateNumber?.consumerPreferredLanguage = ""
        req.validateNumber?.isDelegate = ""
        req.validateNumber?.token = "AppMovil-000000-a3e6-6abd-020a01aa32"
        req.validateNumber?.version = "2.2"
        req.validateNumber?.lineOfBusiness = "1"
        req.validateNumber?.ownerProfileId = ""
        req.validateNumber?.requestingUserId = ""
        req.validateNumber?.userProfileId = ""
        req.validateNumber?.uUID = ""
        
        
        mcaManagerServer.executeValidateNumber(params: req, onSuccess: { (result) in
            self.executeServiceSetToken()
        }) { (result, myError) in
            GeneralAlerts.showAcceptOnly(title: "",
                                         text: (result?.validateNumberResponse?.acknowledgementDescription)!,
                                         icon: .IconoAlertaError,
                                         cancelBtnColor: nil,
                                         cancelButtonName: "",
                                         acceptTitle: NSLocalizedString("accept", comment: ""),
                                         acceptBtnColor: nil,
                                         buttonName: "",
                                         onAcceptEvent: {})
        }
    }
    
    func executeServiceSetToken(){
        
        let req = SetTokenRequest()
        if isNumber(){
            req.setToken?.mobileNumber = lblNumEmail.textField.text!.trimmingCharacters(in: CharacterSet.whitespaces)
            req.setToken?.userProfileId = ""
        }else{
            req.setToken?.mobileNumber = ""
            req.setToken?.userProfileId = lblNumEmail.textField.text!.trimmingCharacters(in: CharacterSet.whitespaces)
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
            let bySMS = RegisterTokenVC();
            bySMS.phoneUser = self.lblNumEmail.textField.text!
            self.navigationController?.pushViewController(bySMS, animated: true)
        }) { (result, myError) in
            
        }
    }
    
}
