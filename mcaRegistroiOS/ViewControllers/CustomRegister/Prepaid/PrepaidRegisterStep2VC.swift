//
//  PrepaidRegisterStep2VC.swift
//  MiClaro
//
//  Created by Pilar del Rosario Prospero Zeferino on 8/21/18.
//  Copyright © 2018 am. All rights reserved.
//

import UIKit
import Cartography
import mcaManageriOS
import mcaUtilsiOS

class PrepaidRegisterStep2VC: UIViewController, MobilePhoneNumberOnChangeDelegate, UITextFieldDelegate {
    
    var doLoginWhenFinish :((_ doAutomaticLogin: Bool) -> Void) = {_ in }
    
    /// Constante que almacena la configuración
    let conf = mcaManagerSession.getGeneralConfig()
    private var headerView : UIHeaderForm = UIHeaderForm(frame: .zero)
    private var textGroup : UITextFieldGroupPhone = UITextFieldGroupPhone(frame: .zero)
    /// Botón para continuar
    var nextButton: RedBorderWhiteBackgroundButton!
    var RUT = ""
    
    func setupElements() {
        self.view.backgroundColor = UIColor.white
        self.initWith(navigationType:.IconBack, headerTitle: conf?.translations?.data?.registro?.header ?? "")
        let scrollView : UIScrollView = UIScrollView(frame: .zero)
        let viewContent : UIView = UIView(frame: self.view.bounds)
        headerView.setupElements(imageName: "ico_seccion_registro", title: conf?.translations?.data?.newRegisterTexts?.newRegisterTitle, subTitle: conf?.translations?.data?.registro?.registerPrepaid)
        viewContent.addSubview(headerView)
        
        var code = conf?.country?.phoneCountryCode
        code = code?.replacingOccurrences(of: " ", with: "+")
        
        textGroup.setupContent(imageName: "icon_telefono_input", text: conf?.translations?.data?.newRegisterTexts?.newRegisterCellphone ?? "", placeHolder: conf?.translations?.data?.newRegisterTexts?.newRegisterCellphone ?? "", countryCodeText: code)
        textGroup.textField.keyboardType = .namePhonePad
        textGroup.textField.delegate = self
        viewContent.addSubview(textGroup)
        
        nextButton = RedBorderWhiteBackgroundButton(textButton: conf?.translations?.data?.generales?.nextBtn ?? "")
        nextButton.addTarget(self, action: #selector(sendSMS), for: UIControlEvents.touchUpInside)
        nextButton.isEnabled = true
        self.nextButton?.isUserInteractionEnabled = false
        self.nextButton?.alpha = 0.5
        viewContent.addSubview(nextButton)
        scrollView.addSubview(viewContent)
        scrollView.frame = viewContent.bounds
        scrollView.contentSize = viewContent.bounds.size
        self.view.addSubview(scrollView)
        
        setupConstraints(view: viewContent)
    }
    
    func setupConstraints(view: UIView) {
        constrain(view, headerView, textGroup, nextButton) { (view, header, group, button) in
            header.top == view.top
            header.leading == view.leading
            header.trailing == view.trailing
            header.height == view.height * 0.35
            
            group.top == header.bottom + 16.0
            group.leading == view.leading + 32.0
            group.trailing == view.trailing - 31.0
            group.height == 60.0
            
            button.top == group.bottom + 24.0
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
        let genericWebViewInfo = GenericWebViewModel(headerTitle: config?.translations?.data?.generales?.termsAndConditions ?? "", serviceSelected: WebViewType.TermsAndConditios, loadUrl: config?.termsAndConditions?.url ?? "", buttonNavType: .IconBack, reloadUrlSuccess: config?.paidServices?.first?.recarga?.urlSuccess, paidUrlSucces: config?.paidServices?.first?.pago?.urlSuccess)
        mcaUtilsHelper.initGenericWebView(navController: self.navigationController, info: genericWebViewInfo)
    }
    /// Función encargada de validar y envíar el SMS para la fase 2 de agregar prepago
    func sendSMS() {
        
        //modalMessage()
        
        AnalyticsInteractionSingleton.sharedInstance.ADBTrackCustomLink(viewName: "Mis servicios|Agregar prepago|Paso 1|Ingresar numero movil:Continuar")
        var message = ""
        var callService = false
        textGroup.mandatoryInformation.hideView()

        if textGroup.textField.text!.isEmpty {
            message = conf?.translations?.data?.generales?.emptyField ?? ""
            callService = false
            AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewServicioPrepago(viewName: "Mis servicios|Agregar prepago|Paso 1|Ingresar numero movil|Detenido", type: "1", detenido: true, mensaje: message)
        }else {
            message = ""
            callService = true
        }
        if callService {
            print("CALL WEB SERVICE")
            self.callWebService()
        }else {
            self.textGroup.mandatoryInformation.displayView(customString: message)
        }
        
    }
    /// Función para determinar cuando se toque cualquier elemento de la vista
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func modalMessage() {
        GeneralAlerts.showAcceptOnly(title: "Error", text: "failure-services".localized, icon: .IconoAlertaSMS,  onAcceptEvent: {})
    }
    
    /// Alerta de insuficiencia de memoria
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// WEB SERVICE VALIDATE IS ASSOCIATED
    func callWebService(){
        textGroup.mandatoryInformation.hideView()
        if false == mcaManagerSession.isNetworkConnected() {
            mcaManagerSession.showOfflineMessage()
            return;
        }
        let telefono = textGroup.textField.text?.trimmingCharacters(in: .whitespaces);
        if "" != telefono, let count = telefono?.count, count >= 8 {
            self.nextStep()
        } else if "" != telefono {
            textGroup.mandatoryInformation.displayView(customString: "eight-digits".localized)
        }
    }
    
    /// SHOW NEXT VIEW
    func nextStep() {
        textGroup.mandatoryInformation.hideView()
        if false == mcaManagerSession.isNetworkConnected() {
            mcaManagerSession.showOfflineMessage()
            return;
        }
        let telefono = textGroup.textField.text?.trimmingCharacters(in: .whitespaces);

        if "" != telefono, let count = telefono?.count, count >= 8 {
            
            let vista = PrepaidRegisterSendMobileVC(nibName: "PrepaidRegisterSendMobileVC", bundle: nil)
            vista.setRUT(r: self.RUT)
            vista.previousView = TypeRegisterView.Prepaid
            vista.lineOfBussines = TypeLineOfBussines.Prepago
            vista.setMobilePhone(r: self.textGroup.textField.text!)
            vista.view.frame = self.view.frame
            vista.doLoginWhenFinish = self.doLoginWhenFinish
            self.navigationController?.pushViewController(vista, animated: true);
        } else if "" != telefono {
            textGroup.mandatoryInformation.displayView(customString: "eight-digits".localized)
        }
    }
    
    /// Función que permite determinar si el texto ingresado son caracteres validos y modifica / agrega / Elimina o no el caracter
    /// - parameter textField: campo de texto que se está editando
    /// - parameter range: Rango de los caracteres
    /// - parameter string: Cadena a anexar
    /// - Returns: Bool
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let lenght = (mcaManagerSession.getGeneralConfig()?.rules?.mobileNumberRules?.mobileMaxLength) ?? ""
        let lenghtStr = (lenght as NSString).integerValue
        //if (mobilePhoneView.mobileTextfield.text != nil) {
        if (textGroup.textField.text != nil) {
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string) as String
            let nsString = NSString(string: newString)
            
            if nsString.length >= lenghtStr {
                self.nextButton?.isUserInteractionEnabled = true
                self.nextButton?.alpha = 1.0
            } else {
                self.nextButton?.isUserInteractionEnabled = false
                self.nextButton?.alpha = 0.5
            }
            
            return !(nsString.length > lenghtStr)
            
        }
        return true
    }
    
}

