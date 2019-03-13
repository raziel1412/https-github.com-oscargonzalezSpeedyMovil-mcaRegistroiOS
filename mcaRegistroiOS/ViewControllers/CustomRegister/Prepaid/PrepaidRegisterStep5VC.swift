//
//  PrepaidRegisterStep5VC.swift
//  MiClaro
//
//  Created by Pilar del Rosario Prospero Zeferino on 8/21/18.
//  Copyright © 2018 am. All rights reserved.
//

import UIKit
import Cartography
import mcaManageriOS
import mcaUtilsiOS

class PrepaidRegisterStep5VC: UIViewController, UITextFieldDelegate {
    
    var doLoginWhenFinish :((_ doAutomaticLogin: Bool) -> Void) = {_ in }
    
    /// Variable que almacena el request del nnúmero
    private var reqNum : ValidateNumberRequest?;
    /// Variable que almacena la pregunta de seguridad
    //private var perQuestions : ValidatePersonalVerificationQuestionRequest?
    /// Texto del password
    var txtPass1 : SimpleGrayTextField?;
    /// Texto de confirmación del password
    var txtPass2 : SimpleGrayTextField?;
    /// Botón para ingresar
    var cmdIngresar : RedBorderWhiteBackgroundButton?;
    /// Arreglo con las validaciones necesarias
    var validationArray = [String]()
    /// Line of business
    var lineOfBussines: TypeLineOfBussines = TypeLineOfBussines.Prepaid
    /// Grupo de constraints
    var grupo : ConstraintGroup?;
    /// Archivo de configuración
    let conf = mcaManagerSession.getGeneralConfig();
    /// Header de la vista
    var headerView : UIHeaderForm = UIHeaderForm(frame: .zero)
    /// Contenedor de Rules
    var passwordRulesContainer : PasswordRulesContainer = PasswordRulesContainer(frame: .zero)
    var mandatoryPass1 : MandatoryInformation = MandatoryInformation(frame: .zero)
    var mandatoryPass2 : MandatoryInformation = MandatoryInformation(frame: .zero)
    var imgSecurity1 = UIImageView()
    var imgSecurity2 = UIImageView()
    
    var RUT = ""
    var numberPhone = ""
    
    //Variables for mixed register
    var accountID = ""
    var email = ""
    
    func setupElements() {
        self.initWith(navigationType:.IconBack, headerTitle: conf?.translations?.data?.registro?.header ?? "")
        view.backgroundColor = institutionalColors.claroWhiteColor;
        headerView.setupElements(imageName: "ico_seccion_registro", title: conf?.translations?.data?.newRegisterTexts?.newRegisterTitle, subTitle: conf?.translations?.data?.newRegisterTexts?.newRegisterLastStepDescription)
        self.view.addSubview(headerView)
        
        let password = conf?.translations?.data?.newRegisterTexts?.newRegisterPassword != nil ? (conf?.translations?.data?.newRegisterTexts?.newRegisterPassword)! : ""
        txtPass1 = SimpleGrayTextField(text: password, placeholder: password);
        txtPass1?.delegate = self;
        txtPass1?.isSecureTextEntry = true;
        txtPass1?.setupSecurityEye()
        //txtPass1?.setupIconText()
        self.view.addSubview(txtPass1!)
        self.view.addSubview(mandatoryPass1)
        
        let confirmPasswordText = conf?.translations?.data?.newRegisterTexts?.newRegisterConfirmPassword != nil ? (conf?.translations?.data?.newRegisterTexts?.newRegisterConfirmPassword)! : ""
        txtPass2 = SimpleGrayTextField(text: confirmPasswordText, placeholder: confirmPasswordText);
        txtPass2?.delegate = self;
        txtPass2?.isSecureTextEntry = true;
        txtPass2?.setupSecurityEye()
        //txtPass2?.setupIconText()
        self.view.addSubview(txtPass2!)
        self.view.addSubview(mandatoryPass2)
        
        passwordRulesContainer.setupContent(title: conf?.translations?.data?.generales?.passwordMustHave, rules: [conf?.translations?.data?.generales?.passwordRule1, conf?.translations?.data?.generales?.passwordRule2, conf?.translations?.data?.generales?.passwordRule3])
        self.view.addSubview(passwordRulesContainer)
        
        let ingresarBtn = (conf?.translations?.data?.generales?.signBtn) != nil ? (conf?.translations?.data?.generales?.signBtn)! : ""
        cmdIngresar = RedBorderWhiteBackgroundButton(textButton: ingresarBtn);
        cmdIngresar?.addTarget(self, action: #selector(confirmPassword), for: UIControlEvents.touchUpInside)
        self.view.addSubview(cmdIngresar!)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        
        constrain(self.view, headerView) { (view, header) in
            header.top == view.top
            header.leading == view.leading
            header.trailing == view.trailing
            header.height == view.height * 0.35
        }
        
        imgSecurity1.image =  mcaUtilsHelper.getImage(image: "icon_contrasena_input")
        imgSecurity1.contentMode = .scaleAspectFit
        imgSecurity1.backgroundColor = UIColor.clear
        self.view.addSubview(imgSecurity1)
        
        imgSecurity2.image =  mcaUtilsHelper.getImage(image: "icon_contrasena_input")
        imgSecurity2.contentMode = .scaleAspectFit
        imgSecurity2.backgroundColor = UIColor.clear
        self.view.addSubview(imgSecurity2)
        
        constrain(self.view, headerView, txtPass1!, mandatoryPass1, imgSecurity1) { (view, header, pass, mandatory, imgSec1) in
            
            imgSec1.top == header.bottom + 16.0 + 10
            imgSec1.leading == view.leading + 31.0
            imgSec1.height == 20.0
            imgSec1.width == 20.0
            
            pass.top == header.bottom + 16.0
            pass.leading == imgSec1.leading + 31.0
            pass.trailing == view.trailing - 32.0
            pass.height == 40.0
            mandatory.top == pass.bottom + 6.0
            mandatory.leading == pass.leading
            mandatory.trailing == pass.trailing
            mandatory.height == 12.0
            
            
        }
        
        constrain(self.view, mandatoryPass1, txtPass2!, mandatoryPass2, imgSecurity2) { (view, header, pass, mandatory, imgSec2) in
            
            imgSec2.top == header.bottom + 16.0 + 10
            imgSec2.leading == view.leading + 31.0
            imgSec2.height == 20.0
            imgSec2.width == 20.0
            
            pass.top == header.bottom + 16.0
            pass.leading == imgSec2.leading + 31.0
            pass.trailing == view.trailing - 32.0
            pass.height == 40.0
            mandatory.top == pass.bottom + 6.0
            mandatory.leading == pass.leading
            mandatory.trailing == pass.trailing
            mandatory.height == 12.0
        }
        
        constrain(self.view, mandatoryPass2, passwordRulesContainer, cmdIngresar!) { (view, pass2, rules, button) in
            rules.top == pass2.bottom + 26.0
            rules.leading == view.leading + 31.0 + 11.0
            rules.trailing == view.trailing - 32.0
            rules.height == 71.0
            
            button.top == rules.bottom + 16.0
            button.leading == view.leading + 31.0
            button.trailing == view.trailing - 32.0
            button.height == 40.0
        }
        
    }
    
    
    /// Funcion encargada de realizar el setup inicial, carga de los frames de los elementos gráficos y contenido.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 5|Ingresar contrasena",type:5, detenido: false)
        
    }
    
    /// Función que evalua si se encuentran todos los requisitos para realizar el llamado al servicio web, de ser así lo realiza y de lo contrario muestra una alerta
    func confirmPassword() {
        
        AnalyticsInteractionSingleton.sharedInstance.ADBTrackCustomLink(viewName: "Registro|Paso 5|Ingresar contrasena:Confirmar")
        
        if txtPass1!.canResignFirstResponder {
            txtPass1?.resignFirstResponder();
        }
        
        if txtPass2!.canResignFirstResponder {
            txtPass2?.resignFirstResponder();
        }
        
        if let count = txtPass1?.text?.count, count > 0, let txt1 = txtPass1?.text, txt1.trimmingCharacters(in: .whitespaces).count > 0, let count2 = txtPass2?.text?.count, count2 > 0, let txt2 = txtPass2?.text, txt2.trimmingCharacters(in: .whitespaces).count > 0 {
            
            if (txtPass1?.text == txtPass2?.text) {
                let req = CreateNewRegisterRequest();
                req.createNewRegister?.isTermsAndConditionsAccepted = "true";
                req.createNewRegister?.isClaroPromotionsAccepted = "true";
                let personal = PersonalDetailsInformation();
                personal.accountUserGender = "";
                personal.accountUserLastName = "";
                personal.accountUserSecondLastName = "";
                personal.city = "";
                personal.accountUserFirstName = "";
                personal.dateOfBirth = "";
                personal.isNotificationAuthorized = "";
                personal.accountUserTaxId = "";
                personal.rUT = self.RUT;
                
                req.createNewRegister?.password = txtPass1?.text
                let pId = PersonalId();
                pId.identificationNumber = self.RUT;
                pId.identificationType = "1";
                personal.personalId = [pId];
                
                req.createNewRegister?.personalDetailsInformation = personal;
                req.createNewRegister?.userProfileId = self.RUT
                req.createNewRegister?.lineOfBusiness = self.lineOfBussines.rawValue
                req.createNewRegister?.accountId = ""
                req.createNewRegister?.isDelegate = "false";
                req.createNewRegister?.countryCode = mcaManagerSession.getCurrentCountry();
                if self.lineOfBussines == .Fixed {
                    req.createNewRegister?.accountId = self.accountID
                    req.createNewRegister?.email = self.email
                }
                
                let typeLoB = self.lineOfBussines == .Prepaid ? "1" : self.lineOfBussines == .Postpaid ? "2" : self.lineOfBussines == .Fixed ? "3" : ""
                
                
                mcaManagerServer.executeCreateNewRegister(params: req, onSuccess: { (result, resultType) in
                                                                    
                    switch self.lineOfBussines {
                    case .Fixed:
                        let onAcceptEvent = {
                            self.automaticLogin()
                        }
                        
                        GeneralAlerts.showAcceptOnly(title: self.conf?.translations?.data?.generales?.successTitle ?? "¡Felicidades!", text: self.conf?.translations?.data?.registro?.registerSuccessText ?? "Tu cuenta Mi Claro se ha creado exitosamente", icon: AlertIconType.IconoAlertaFelicidades, acceptTitle: self.conf?.translations?.data?.generales?.confirmBtn ?? "Confirmar", onAcceptEvent: onAcceptEvent)
                        
                        AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Exito",type:7, detenido: false, typeLoB: typeLoB)
                        
                        break
                    case .Prepaid:
                        
                        let onAcceptEvent = {
                            self.callWSAssociateAccount()
                        }
                        
                         GeneralAlerts.showAcceptOnly(title: self.conf?.translations?.data?.generales?.successTitle ?? "¡Felicidades!", text: self.conf?.translations?.data?.registro?.registerSuccessText ?? "Tu cuenta Mi Claro se ha creado exitosamente", icon: AlertIconType.IconoAlertaFelicidades, acceptTitle: self.conf?.translations?.data?.generales?.confirmBtn ?? "Confirmar", onAcceptEvent: onAcceptEvent)
                    
                        AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Exito",type:7, detenido: false, typeLoB: typeLoB)
                        
                        break
                    case .Postpaid:
                        let onAcceptEvent = {
                            self.automaticLogin()
                        }
                        GeneralAlerts.showAcceptOnly(title: self.conf?.translations?.data?.generales?.successTitle ?? "¡Felicidades!", text: self.conf?.translations?.data?.registro?.registerSuccessText ?? "Tu cuenta Mi Claro se ha creado exitosamente", icon: AlertIconType.IconoAlertaFelicidades, acceptTitle: self.conf?.translations?.data?.generales?.confirmBtn ?? "Confirmar", onAcceptEvent: onAcceptEvent)
                        
                        AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Exito",type:7, detenido: false, typeLoB: typeLoB)
                        
                    }
                                                                    
                                                                    
                }, onFailure: { (result, myError) in
                    GeneralAlerts.showAcceptOnly(text: result?.createNewRegisterResponse?.acknowledgementDescription ?? "", icon: .IconoAlertaError, onAcceptEvent: {})
                });
                
            } else {
                mandatoryPass2.displayView(customString: conf?.translations?.data?.generales?.passwordSameError)
            }
            
        } else {
            mandatoryPass1.displayView()
            mandatoryPass2.displayView()
        }
    }
    
    func callWSAssociateAccount() {
        
        let req = AssociateAccountRequest()
        req.associateAccount = AssociateAccount()
        req.associateAccount?.lineOfBusiness = self.lineOfBussines.rawValue
        req.associateAccount?.accountId = self.reqNum?.validateNumber?.claroNumber
        req.associateAccount?.userProfileId = self.reqNum?.validateNumber?.userProfileId//self.rutUser
        req.associateAccount?.associationRoleType = "1"
        req.associateAccount?.accountAssociationStatus = "1"
        req.associateAccount?.notifyMeAboutChanges = true
        
        mcaManagerServer.executeAssociateAccount(params: req, onSuccess: {
            (associateResult, resultType) in
    
            self.automaticLogin()

        }, onFailure: {(result, error) in
            
            let onAcceptEvent = {
                if let container = self.so_containerViewController {
                    container.isSideViewControllerPresented = false;
                }
            }
            
            GeneralAlerts.showAcceptOnly(text: result?.associateAccountResponse?.acknowledgementDescription ?? "", icon: AlertIconType.IconoAlertaError, acceptTitle: NSLocalizedString("accept", comment: ""), onAcceptEvent: onAcceptEvent)
        })
    }
    
    /// Función que es llamada luego de hacer el recovery exitosamente, encargada para realizar el login
    func automaticLogin() {
        let req = RetrieveProfileInformationRequest();
        req.retrieveProfileInformation?.lineOfBusiness = lineOfBussines.rawValue
        req.retrieveProfileInformation?.userProfileId = self.RUT
        
        mcaManagerServer.executeRetrieveProfileInformation(params: req,
                                                                 onSuccess: { (result) in
                                                                    print(result);
                                                                    DispatchQueue.main.async(execute: {
                                                                        self.didFinishModuleDoingAutomaticLogin()
                                                                    })
        },
                                                                 onFailure: { (result, myError) in
                                                                    self.didFinishModuleDoingAutomaticLogin() 
                                                                    
        });
    }
    
    /// callback of VC that launch current module
    func didFinishModuleDoingAutomaticLogin() {
        doLoginWhenFinish(true)
    }

    /// Función que setea el número
    /// - parameter r: ValidateNumberRequest
    func setValidateNumber(r : ValidateNumberRequest?) {
        self.reqNum = r;
    }
    /// Función que permite cambiar el status del check de términos y condiciones
    /// - parameter sender: Any
    func lnkTerminos_OnClick(sender: Any) {
        if false == mcaManagerSession.isNetworkConnected() {
            mcaManagerSession.showOfflineMessage()
            return;
        }
        let config = mcaManagerSession.getGeneralConfig()
        let genericWebViewInfo = GenericWebViewModel(headerTitle: config?.translations?.data?.generales?.termsAndConditions ?? "", serviceSelected: WebViewType.TermsAndConditions, loadUrl: config?.termsAndConditions?.url ?? "", buttonNavType: .IconBack, reloadUrlSuccess: config?.paidServices?.first?.recarga?.urlSuccess, paidUrlSucces: config?.paidServices?.first?.pago?.urlSuccess)
        self.navigationController?.pushViewController(GenericWebViewVC(info: genericWebViewInfo), animated: true)
    }
    
    /// Función que es llamada al tocar cualquier elemento de la pantalla, para llamar al endEditing
    /// - parameter touches: Set<UITouch>
    /// - parameter event : UIEvent?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    /// Alerta de insuficiencia de memoria
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Validación para el password
    /// - parameter pass: String de validación
    func validate(pass : String) -> (hasError : Bool, errorString : String?){
        
        let numberRegEx  = ".*[0-9]+.*"
        let texttest1 = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let numberresult = texttest1.evaluate(with: pass)
        if !numberresult {
            //"passwordRuleError": "El formato de la contraseña es incorrecto.",
            return (true, conf?.translations?.data?.generales?.passwordRuleError)
        }
        
        let letterRegEx  = ".*[a-z]+.*"
        let texttest = NSPredicate(format:"SELF MATCHES %@", letterRegEx)
        let letterresult = texttest.evaluate(with: pass.lowercased())
        if !letterresult {
            //"passwordRuleError": "El formato de la contraseña es incorrecto.",
            return (true, conf?.translations?.data?.generales?.passwordRuleError)
        }
        
        let specialCharacterRegEx  = ".*[*^'-]+.*"
        let texttest2 = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
        let specialresult = texttest2.evaluate(with: pass)
        if specialresult {
            //"passwordRuleError": "El formato de la contraseña es incorrecto.",
            return (true, conf?.translations?.data?.generales?.passwordRuleError)
        }
        
        return (false, nil)
        //"passwordSameError": "La contraseña no coincide.",
        
        
    }
    
    /// Función que permite determinar si el texto ingresado son caracteres validos y modifica / agrega / Elimina o no el caracter
    /// - parameter textField: campo de texto que se está editando
    /// - parameter range: Rango de los caracteres
    /// - parameter string: Cadena a anexar
    /// - Returns: Bool
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.count + string.count - range.length
        if (txtPass1 == textField) {
            if newLength == 0 {
                mandatoryPass1.displayView()
                AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 5|Ingresar contrasena|Detenido",type:5, detenido: true, mensaje:"error")
            } else {
                let str = textField.text! as NSString
                let cad = str.replacingCharacters(in: range, with: string)
                let validateResult = self.validate(pass: cad);
                if validateResult.hasError == true {
                    mandatoryPass1.displayView(customString: validateResult.errorString)
                    AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 5|Ingresar contrasena|Detenido",type:5, detenido: true, mensaje:validateResult.errorString)
                } else {
                    mandatoryPass1.hideView()
                }
            }
        }
        
        if (txtPass2 == textField) {
            if newLength == 0 {
                mandatoryPass2.displayView()
                AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 5|Ingresar contrasena|Detenido",type:5, detenido: true, mensaje:"error")
            } else {
                let str = textField.text! as NSString
                let cad = str.replacingCharacters(in: range, with: string)
                let validateResult = self.validate(pass: cad);
                if validateResult.hasError == true {
                    mandatoryPass2.displayView(customString: validateResult.errorString)
                    AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 5|Ingresar contrasena",type:5, detenido: true, mensaje:validateResult.errorString)
                } else {
                    mandatoryPass2.hideView()
                }
            }
        }
        
        
        
        
        return newLength <= 12 // Bool
        
    }
    
}
