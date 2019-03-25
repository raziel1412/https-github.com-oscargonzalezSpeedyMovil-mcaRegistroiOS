//
//  PrepaidRegisterPasswordVC.swift
//  MiClaro
//
//  Created by Roberto Gutierrez Resendiz on 01/08/17.
//  Copyright © 2017 am. All rights reserved.
//

import UIKit
import Cartography
import mcaUtilsiOS
import mcaManageriOS

/// Clase encargada de validar el código de verificación del registro
class PrepaidRegisterPasswordVC: UIViewController, UITextFieldDelegate {
    
    var doLoginWhenFinish :((_ doAutomaticLogin: Bool) -> Void) = {_ in }
    
    /// Variable que almacena el request del nnúmero
    private var reqNum : ValidateNumberRequest?;
    /// Variable que almacena la pregunta de seguridad
    private var perQuestions : ValidatePersonalVerificationQuestionRequest?
    /// Texto del password
    var txtPass1 : SimpleGrayTextField?;
    /// Texto de confirmación del password
    var txtPass2 : SimpleGrayTextField?;
    /// Botón para ingresar
    var cmdIngresar : RedBorderWhiteBackgroundButton?;
    /// Arreglo con las validaciones necesarias
    var validationArray = [String]()
    /// Line of business
    var lineOfBussines: TypeLineOfBussines?
    /// Grupo de constraints
    var grupo : ConstraintGroup?;
    /// Archivo de configuración
    let conf = mcaManagerSession.getGeneralConfig()
    /// Header de la vista
    var headerView : UIHeaderForm = UIHeaderForm(frame: .zero)
    /// Contenedor de Rules
    var passwordRulesContainer : PasswordRulesContainer = PasswordRulesContainer(frame: .zero)
    var mandatoryPass1 : MandatoryInformation = MandatoryInformation(frame: .zero)
    var mandatoryPass2 : MandatoryInformation = MandatoryInformation(frame: .zero)
    
    func setupElements() {
        self.initWith(navigationType:.IconBack, headerTitle: conf?.translations?.data?.registro?.header ?? "")
        view.backgroundColor = institutionalColors.claroWhiteColor;
        headerView.setupElements(imageName: "ico_seccion_registro", title: conf?.translations?.data?.registro?.header, subTitle: conf?.translations?.data?.registro?.registerThirdStep)
        self.view.addSubview(headerView)
        
        let password = conf?.translations?.data?.generales?.password != nil ? (conf?.translations?.data?.generales?.password)! : ""
        txtPass1 = SimpleGrayTextField(text: password, placeholder: password);
        txtPass1?.delegate = self;
        txtPass1?.isSecureTextEntry = true;
        txtPass1?.setupSecurityEye()
        self.view.addSubview(txtPass1!)
        self.view.addSubview(mandatoryPass1)
        
        let confirmPasswordText = conf?.translations?.data?.generales?.confirmPassword != nil ? (conf?.translations?.data?.generales?.confirmPassword)! : ""
        txtPass2 = SimpleGrayTextField(text: confirmPasswordText, placeholder: confirmPasswordText);
        txtPass2?.delegate = self;
        txtPass2?.isSecureTextEntry = true;
        txtPass2?.setupSecurityEye()
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
        
        constrain(self.view, headerView, txtPass1!, mandatoryPass1) { (view, header, pass, mandatory) in
            pass.top == header.bottom + 16.0
            pass.leading == view.leading + 31.0
            pass.trailing == view.trailing - 32.0
            pass.height == 40.0
            mandatory.top == pass.bottom + 6.0
            mandatory.leading == pass.leading
            mandatory.trailing == pass.trailing
            mandatory.height == 12.0
        }
        
        constrain(self.view, mandatoryPass1, txtPass2!, mandatoryPass2) { (view, header, pass, mandatory) in
            pass.top == header.bottom + 16.0
            pass.leading == view.leading + 31.0
            pass.trailing == view.trailing - 32.0
            pass.height == 40.0
            mandatory.top == pass.bottom + 6.0
            mandatory.leading == pass.leading
            mandatory.trailing == pass.trailing
            mandatory.height == 12.0
        }
        
        
        constrain(self.view, mandatoryPass2, passwordRulesContainer, cmdIngresar!) { (view, pass2, rules, button) in
            rules.top == pass2.bottom + 26.0
            rules.leading == view.leading + 31.0
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
        
        let typeLoB = self.lineOfBussines == .Prepaid ? "1" : self.lineOfBussines == .Postpaid ? "2" : self.lineOfBussines == .Fixed ? "3" : ""
        
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
                personal.rUT = perQuestions?.validatePersonalVerificationQuestions?.userProfileId;
                
                for item in perQuestions!.validatePersonalVerificationQuestions!.securityQuestions! {
                    if "1" == item.idQuestion {
                        req.createNewRegister?.userProfileId = item.answer
                    }else if "3" == item.idQuestion {
                        req.createNewRegister?.email = item.answer
                    }
                }
                
                req.createNewRegister?.password = txtPass1?.text
                let pId = PersonalId();
                pId.identificationNumber = perQuestions?.validatePersonalVerificationQuestions?.userProfileId;
                pId.identificationType = "1";
                personal.personalId = [pId];
                
                req.createNewRegister?.personalDetailsInformation = personal;
                req.createNewRegister?.userProfileId = perQuestions?.validatePersonalVerificationQuestions?.userProfileId;
                req.createNewRegister?.lineOfBusiness = self.lineOfBussines?.rawValue//"0"
                req.createNewRegister?.accountId = ""
                req.createNewRegister?.isDelegate = "false";
                req.createNewRegister?.countryCode = mcaManagerSession.getCurrentCountry()
                
                
                mcaManagerServer.executeCreateNewRegister(params: req,
                                                                onSuccess: { (result) in
                                                                    self.guardaPassword();
                },
                                                                onFailure: { (result, myError) in
                                                                    /******************************************/
                                                                    GeneralAlerts.showAcceptOnly(text: result?.createNewRegisterResponse?.acknowledgementDescription ?? "", icon: AlertIconType.IconoAlertaError, onAcceptEvent: {})
                                                        
                                                          
                                               
                                          
                });
                
            } else {
                mandatoryPass2.displayView(customString: conf?.translations?.data?.generales?.passwordSameError)
                AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 6|Ingresar contrasena|Detenido",type:6, detenido: true, mensaje: conf?.translations?.data?.generales?.passwordSameError, typeLoB: typeLoB)
            }
        } else {
            mandatoryPass1.displayView()
            mandatoryPass2.displayView()
            
            AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 6|Ingresar contrasena|Detenido",type:6, detenido: true, mensaje:mcaManagerSession.getGeneralConfig()?.translations?.data?.generales?.emptyField, typeLoB: typeLoB)
        }
    }
    /// Función para guardar el password y verifica la pregunta de seguridad, de todo ir bien llevara al login
    func guardaPassword() {
        
        let req = UpdatePasswordRequest();
        req.updatePassword?.userProfileId = perQuestions?.validatePersonalVerificationQuestions?.userProfileId;
        req.updatePassword?.password = txtPass1?.text;
        req.updatePassword?.lineOfBusiness = "0"
        
        mcaManagerServer.executeUpdatePassword(params: req,
                                                     onSuccess: { (result) in
                                                        
                                                        let onAcceptEvent = {
                                                            self.automaticLogin()
                                                              AnalyticsInteractionSingleton.sharedInstance.ADBTrackCustomLink(viewName: "Registro|Exito:Cerrar")
                                                        }
                                                        
                                                        GeneralAlerts.showAcceptOnly(title: self.conf?.translations?.data?.registro?.registerSuccessTitle ?? "", text: self.conf?.translations?.data?.registro?.registerSuccessText ?? "", icon: .IconoAlertaSMS, acceptTitle: self.conf?.translations?.data?.generales?.acceptBtn ?? "", acceptBtnColor: institutionalColors.claroBlueColor, onAcceptEvent: onAcceptEvent)
                                                        
                                                        
                                                        AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Exito",type:6, detenido: false)
                                                      
                                                        
        },
                                                     onFailure: { (result, myError) in
                                                        GeneralAlerts.showAcceptOnly(text: result?.updatePasswordResponse?.acknowledgementDescription ?? "", icon: AlertIconType.IconoAlertaError, onAcceptEvent: {})
        });
        
    }
    
    /// Función que es llamada luego de hacer el recovery exitosamente, encargada para realizar el login
    func automaticLogin() {
        let req = RetrieveProfileInformationRequest();
        req.retrieveProfileInformation?.lineOfBusiness = "0";
        req.retrieveProfileInformation?.userProfileId = perQuestions?.validatePersonalVerificationQuestions?.userProfileId
        
        mcaManagerServer.executeRetrieveProfileInformation(params: req,
                                                                 onSuccess: { (result) in
                                                                    print(result);
                                                                    DispatchQueue.main.async(execute: {
                                                                        self.didFinishModuleDoingAutomaticLogin()
                                                                    })
        },
                                                                 onFailure: { (result, myError) in
                                                                    GeneralAlerts.showAcceptOnly(title: "404-response-profile-information", icon: AlertIconType.IconoAlertaError, onAcceptEvent: {})
        });
    }
    
    /// callback of VC that launch current module
    func didFinishModuleDoingAutomaticLogin() {
        doLoginWhenFinish(true)
    }
    
    /// Función para hacer el set de la pregunta de seguridad
    /// - parameter r: ValidatePersonalVerificationQuestionRequest
    func setPersonalQuestions(r : ValidatePersonalVerificationQuestionRequest?) {
        self.perQuestions = r;
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
        
        GeneralAlerts.showDataWebView(title: mcaManagerSession.getGeneralConfig()?.translations?.data?.generales?.termsAndConditions ?? "", url: mcaManagerSession.getGeneralConfig()?.termsAndConditions?.url ?? "", method: "GET", acceptTitle: mcaManagerSession.getGeneralConfig()?.translations?.data?.generales?.closeBtn ?? "", onAcceptEvent: {})
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
            } else {
                let str = textField.text! as NSString
                let cad = str.replacingCharacters(in: range, with: string)
                let validateResult = self.validate(pass: cad);
                if validateResult.hasError == true {
                    mandatoryPass1.displayView(customString: validateResult.errorString)
                } else {
                    mandatoryPass1.hideView()
                }
            }
        }
        
        if (txtPass2 == textField) {
            if newLength == 0 {
                mandatoryPass2.displayView()
            } else {
                let str = textField.text! as NSString
                let cad = str.replacingCharacters(in: range, with: string)
                let validateResult = self.validate(pass: cad);
                if validateResult.hasError == true {
                    mandatoryPass2.displayView(customString: validateResult.errorString)
                } else {
                    mandatoryPass2.hideView()
                }
            }
        }
        
        
        
        
        return newLength <= 12 // Bool
        
    }
    
}
