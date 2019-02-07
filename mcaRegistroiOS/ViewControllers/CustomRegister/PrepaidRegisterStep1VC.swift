//
//  PrepaidRegisterStep1VC.swift
//  MiClaro
//
//  Created by Pilar del Rosario Prospero Zeferino on 8/21/18.
//  Copyright © 2018 am. All rights reserved.
//

import UIKit
import Cartography
import SwiftValidator
import mcaUtilsiOS
import mcaManageriOS

class PrepaidRegisterStep1VC: UIViewController, MobilePhoneNumberOnChangeDelegate, UITextFieldDelegate, ValidationDelegate {
    
    var doLoginWhenFinish :((_ doAutomaticLogin: Bool) -> Void) = {_ in }
    
    /// Constante que almacena la configuración
    let conf = mcaManagerSession.getGeneralConfig()
    private var headerView : UIHeaderForm = UIHeaderForm(frame: .zero)
    private var txtRut : UITextFieldGroup = UITextFieldGroup(frame: .zero)
    private var instructionLbl : InstructionLabel = InstructionLabel(text: "", fontSize: CGFloat(14), alignText: .left)
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
        
        headerView.setupElements(imageName: "ico_seccion_registro", title: conf?.translations?.data?.newRegisterTexts?.newRegisterTitle ?? "", subTitle: conf?.translations?.data?.newRegisterTexts?.newRegisterDescriptionStep1 ?? "")
        
        viewContent.addSubview(headerView)
        
        txtRut.setupContent(imageName: "icon_rut_input", text: conf?.translations?.data?.newRegisterTexts?.newRegisterUserProfileId ?? "", placeHolder: conf?.translations?.data?.newRegisterTexts?.newRegisterUserProfileId ?? "")
        //textGroup.changeFont(font: UIFont(name: RobotoFontName.RobotoBlack.rawValue, size: CGFloat(14.0))!)
        txtRut.textField.delegate = self
        txtRut.textField.keyboardType = .asciiCapable
        txtRut.textField.autocorrectionType = .no
        txtRut.textField.addTarget(self, action: #selector(textFieldDidBeginEditing(_:)), for: .editingDidBegin)
        txtRut.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        txtRut.textField.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        validador?.registerField(txtRut.textField, rules: [RequiredRule(message: "empty-fields".localized)])
        viewContent.addSubview(txtRut)
        
        instructionLbl.text = conf?.translations?.data?.newRegisterTexts?.newRegisterSubStep1 ?? ""
        viewContent.addSubview(instructionLbl)
        
        let parte1 = conf?.translations?.data?.newRegisterTexts?.newRegisterTyCFirst ?? "";
        let parte2 = conf?.translations?.data?.generales?.termsAndConditions ?? "";
        let parte3 = conf?.translations?.data?.newRegisterTexts?.newRegisterTyCFinal ?? "";
        
        
        termsConditions.setContent(String(format: "%@ <b>%@</b> %@", parte1, parte2, parte3), url: mcaManagerSession.getGeneralConfig()?.termsAndConditions?.url ?? "", title: mcaManagerSession.getGeneralConfig()?.translations?.data?.generales?.termsAndConditions ?? "", acceptTitle: mcaManagerSession.getGeneralConfig()?.translations?.data?.generales?.closeBtn ?? "", offlineAction: {
            mcaManagerSession.showOfflineMessage()
        })
        termsConditions.setupClickDelegate(target: self, action: #selector(self.lnkTerminos_OnClick(sender:)))
        viewContent.addSubview(termsConditions)
        termsConditions.checkBox.addTarget(self, action: #selector(self.chkValidate), for: UIControlEvents.touchUpInside)
        
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
        
        if txtRut.isFirstResponder {
            txtRut.resignFirstResponder();
        }
        
        if let text = txtRut.textField.text, text.count > 0{
            let maskedRut = text.enmascararRut()
            if let errorString = maskedRut.errorString {
                txtRut.mandatoryInformation.displayView(customString: errorString)
            } else {
                //IdentifyUserLob - Validar si usuario está registrado
                let params = IdentifyUserLoBRequest()
                let identifyUserLoB = IdentifyUserLoB()
                params.identifyUserLoB = identifyUserLoB
                params.identifyUserLoB?.lineOfBusiness = "0"
                params.identifyUserLoB?.userProfileId = txtRut.textField.text
                
                mcaManagerServer.executeIdentifyUserLoB(params: params, onSuccess: {(LoBResult, resultType) in
                    
                    let isRegistered = LoBResult.identifyUserLoBResponse?.isRegistered ?? false
                 
                    if isRegistered {
                        GeneralAlerts.showAcceptOnly(title: "Cliente Registrado", icon: AlertIconType.IconoAlertaError, acceptTitle: self.conf?.translations?.data?.generales?.confirmBtn ?? "Confirmar", onAcceptEvent: {})
                    } else {
                        let LoB = LoBResult.identifyUserLoBResponse?.loB ?? 0
                        //let LoB = -1
    
                        switch LoB {
                        case 1: //Fijo
                            let nextVC = Fixed02ViewController()
                            nextVC.RUT = self.txtRut.textField.text ?? ""
                            nextVC.doLoginWhenFinish = self.doLoginWhenFinish
                            self.navigationController?.pushViewController(nextVC, animated: true);
                            break
                        case 2, -1: //Prepago
                            let nextVC = PrepaidRegisterStep2VC()
                            nextVC.doLoginWhenFinish = self.doLoginWhenFinish
                            nextVC.RUT = self.txtRut.textField.text ?? ""
                            self.navigationController?.pushViewController(nextVC, animated: true);
                            break
                        case 3: //Pospago y Mixto
                            let nextVC = Postpaid_Mixed02()
                            nextVC.doLoginWhenFinish = self.doLoginWhenFinish
                            nextVC.rut = self.txtRut.textField.text ?? ""
                            self.navigationController?.pushViewController(nextVC, animated: true)
                        default:
                            GeneralAlerts.showAcceptOnly(title: "Error", text: "failure-services".localized, icon:.IconoAlertaSMS, onAcceptEvent: {})
                            break
                        }
                    }

                }, onFailure: {(result, myError) in
                    if(result?.identifyUserLoBResponse?.acknowledgementCode == "ASSCM-ACCMAN-IDNUSRLOB-BSERR-0"){
                        GeneralAlerts.showAcceptOnly(text: "RUT INVALIDO", icon: .IconoAlertaError, onAcceptEvent: {})
                    }else{
                        GeneralAlerts.showAcceptOnly(text: result?.identifyUserLoBResponse?.acknowledgementDescription ?? "", icon: .IconoAlertaError, onAcceptEvent: {})
                    }
                })
            }
        } else {
            // RUT VACIO
            if (txtRut.textField.text?.isEmpty == true){
                let lbEmptyField = (conf?.translations?.data?.generales?.emptyField) ?? ""
                txtRut.mandatoryInformation.displayView(customString: lbEmptyField)
                
                AnalyticsInteractionSingleton.sharedInstance.ADBTrackView(viewName: "Registro|Paso 1|Ingresar RUT|Detenido", detenido: true, mensaje: lbEmptyField)
            }
        }
    }
    
    @objc func chkValidate(){
        if txtRut.textField.canResignFirstResponder {
            txtRut.textField.resignFirstResponder()
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
        constrain(view, headerView, txtRut,instructionLbl, termsConditions) { (view, header, group, instruction, box) in
            header.top == view.top
            header.leading == view.leading
            header.trailing == view.trailing
            header.height == view.height * 0.35
            
            group.top == header.bottom + 16.0
            group.leading == view.leading + 32.0
            group.trailing == view.trailing - 31.0
            group.height == 60.0
            
            instruction.top == group.bottom + 16.0
            instruction.leading == view.leading + 32.0
            instruction.trailing == view.trailing - 31.0
            instruction.height == 60.0
            
            box.top == instruction.bottom + 16.0
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
        mcaUtilsHelper.initGenericWebView(navController: self.navigationController, info: genericWebViewInfo)
        
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
    
    /// WEB SERVICE VALIDATE NUMBER
    func callWebService() {
        txtRut.mandatoryInformation.hideView()
        if false == mcaManagerSession.isNetworkConnected() {
            mcaManagerSession.showOfflineMessage()
            return
        }
        
        let IdentificationNumber = txtRut.textField.text ?? ""
        let maskedString = IdentificationNumber.enmascararRut()
        if let errorString = maskedString.errorString {
            txtRut.mandatoryInformation.displayView(customString:errorString)
            return
        }
        
        
    }
    
    /// Función que permite determinar si el texto ingresado son caracteres validos y modifica / agrega / Elimina o no el caracter
    /// - parameter textField: campo de texto que se está editando
    /// - parameter range: Rango de los caracteres
    /// - parameter string: Cadena a anexar
    /// - Returns: Bool
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var maxText = 12
        maxText = (mcaManagerSession.getGeneralConfig()?.country?.userProfileIdConfig?.max)! - 1 //10
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string) as String
        let nsString = NSString(string: newString)
        if nsString.length > maxText {
            return false
        }else {
            return true
        }
    }
    
    ///Cuando se finaliza la edicion del textfiel txtUser automaticamente se enmascara el IdentificationNumber
    func textFieldDidEndEditing(_ textField: UITextField) {
        let IdentificationNumber = txtRut.textField.text ?? ""
        let maskedString = IdentificationNumber.enmascararRut()
        txtRut.textField.text = maskedString.maskedString
        if let errorString = maskedString.errorString {
            txtRut.mandatoryInformation.displayView(customString:errorString)
        }
    }
    
    /// Función que permite determinar cuando un campo de texto ha iniciado su edición, se setea un tipo de teclado para esta vista
    /// - parameter textField: campo de texto que se está editando
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.keyboardType = .asciiCapable
        if let currentText = textField.text, let separator = mcaManagerSession.getGeneralConfig()?.country?.userProfileIdConfig?.separador {
            textField.text = currentText.replacingOccurrences(of: separator, with: "")
        }
    }
    
    ///Valida txtRut
    func textFieldDidChange(_ textField: UITextField) {
        if let currentText = textField.text, let separator = mcaManagerSession.getGeneralConfig()?.country?.userProfileIdConfig?.separador, currentText.contains(separator) {
            textField.text = currentText.replacingOccurrences(of: separator, with: "")
        }
    }
    
    /// Función que evalua si todo esta correcto y realiza la llamada al Servicio Web
    func validationSuccessful() {
        
        txtRut.resignFirstResponder()
        
        if txtRut.canResignFirstResponder {
            txtRut.resignFirstResponder();
        }
        
        if txtRut.textField.text == "" {
            GeneralAlerts.showAcceptOnly(text: "empty-fields".localized, icon: .IconoAlertaError, onAcceptEvent: {})
        }
    }
    /// Función encargada de notificar si existe algún tiempo
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        //clearCells()
        errors.forEach({ error in
            print(error)
            if let errorField =  error.1.field as? SimpleGrayTextField {
                print("an error")
            }
        })
    }
    
}
