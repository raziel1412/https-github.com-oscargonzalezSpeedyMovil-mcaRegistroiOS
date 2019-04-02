//
//  CompleteRegisterDBViewController.swift
//  MiClaro
//
//  Created by Jonathan Abimael Cruz Orozco and Jorge Isaí García Reyes on 16/08/18.
//  Copyright © 2018 am. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import SwiftValidator
import mcaUtilsiOS
import mcaManageriOS
import mcaWelcomeiOS

public class CompleteRegisterDBViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var viewContainerScroll: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var txfName : SimpleGrayTextFieldQuestionMark!
    @IBOutlet weak var txfEmail : SimpleGrayTextFieldQuestionMark!
    @IBOutlet weak var txfPhone : SimpleGrayTextFieldQuestionMark!
    @IBOutlet weak var txfPassword : SimpleGrayTextFieldQuestionMark!
    @IBOutlet weak var txfConfirmPassword : SimpleGrayTextFieldQuestionMark!
    @IBOutlet weak var btnContinue: UIButton!
    
    @IBOutlet weak var lblTilteView: UILabel!
    @IBOutlet weak var lblDesView: UILabel!
    @IBOutlet weak var lbPasswordMustHave: UILabel!
    @IBOutlet weak var lbPasswordRule1: UILabel!
    @IBOutlet weak var lbPasswordRule2: UILabel!
    @IBOutlet weak var lbPasswordRule3: UILabel!
    
    @IBOutlet weak var iconHeader: UIImageView!
    @IBOutlet weak var iconName: UIImageView!
    @IBOutlet weak var iconEmail: UIImageView!
    @IBOutlet weak var iconPhone: UIImageView!
    @IBOutlet weak var iconPassOne: UIImageView!
    @IBOutlet weak var iconPassTwo: UIImageView!
    @IBOutlet weak var viewContainerDescriptionPass: UIView!
    
    @IBOutlet weak var topConstraintPassword: NSLayoutConstraint!
    @IBOutlet weak var topConstraintButtonContinue: NSLayoutConstraint!
    
    private var conf : GeneralConfig?
    
    private var accounts : [ServiceAccount]?
    
    ///Etiqueta que muestra la informacion de la variable strTerminosYCondiciones
    var lblTerminos : LinkableLabel?;
    ///Bandera para conocer si se puede ejecutar la funcion send
    var chkTerminos : SquaredCheckbox?;
    ///Variable que contiene generales?.emptyField ?
    var lbEmptyField = String()
    ///Variable que contiene generales?.passwordSameError
    var lbPasswordSameError = String()
    ///Variable que contiene generales?.passwordRuleError
    var lbPasswordRuleError = String()
    ///Objeto de tipo MandatoryInformation para Name
    var txtMandatoryName : MandatoryInformation!
    ///Objeto de tipo MandatoryInformation para Email
    var txtMandatoryEmail : MandatoryInformation!
    ///Objeto de tipo MandatoryInformation para Phone
    var txtMandatoryPhone : MandatoryInformation!
    ///Objeto de tipo MandatoryInformation para Pass
    var txtMandatoryPass : MandatoryInformation!
    ///Objeto de tipo MandatoryInformation para Confirm Pass
    var txtMandatoryConfirmPass : MandatoryInformation!
    
    public var didFinishRegister: () -> () = {}

    private var validador : Validator?
    private var bUpDateProfile : Bool = false

    lazy var cancelButton: UIButton = {
        let button  = UIButton()
        button.setTitle("Cancelar", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(institutionalColors.claroBlueColor, for: .normal)
        button.titleLabel?.font = UIFont(name: RobotoFontName.RobotoMedium.rawValue, size: CGFloat(17.0))
        button.borderWidth = 1
        button.borderColor = institutionalColors.claroBlueColor
//        button.addTarget(self, action: #selector(self.leftButtonAction), for: UIControlEvents.touchUpInside)
        
        return button
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
//        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 30)
        iconHeader.image = mcaUtilsHelper.getImage(image: "ico_seccion_registro")
        iconName.image = mcaUtilsHelper.getImage(image: "ico_rut")
        iconEmail.image = mcaUtilsHelper.getImage(image: "icon_correo_input")
        iconPhone.image = mcaUtilsHelper.getImage(image: "icon_telefono_input")
        iconPassOne.image = mcaUtilsHelper.getImage(image: "icon_contrasena_input")
        iconPassTwo.image = mcaUtilsHelper.getImage(image: "icon_contrasena_input")
         self.initWith(navigationType: .IconBack, headerTitle: conf?.translations?.data?.digitalBirthTexts?.digitalBirthTitle ?? "")
        
        
        conf = mcaManagerSession.getGeneralConfig()
        
        lbEmptyField  = conf?.translations?.data?.generales?.emptyField ?? ""
        lbPasswordSameError = conf?.translations?.data?.generales?.passwordSameError ?? ""
        lbPasswordRuleError = conf?.translations?.data?.generales?.passwordRuleError ?? ""
        
        let label = UILabel()
        label.text = conf?.translations?.data?.digitalBirthTexts?.digitalBirthWelcome
        label.textColor = institutionalColors.claroRedColor
        label.textAlignment = NSTextAlignment.left
        label.frame = CGRect(x: 30, y: 0.0, width: self.view.frame.width - 60, height: 0.35 * 44)
        let fuente = UIFont(name: RobotoFontName.RobotoMedium.rawValue, size: CGFloat(18));
        label.font = fuente;
        label.backgroundColor = UIColor.clear
        self.navigationItem.titleView = label
        
        let iconImage = UIImageView(image: UIImage(named: "ico_logo"))
        iconImage.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width * 0.144, height: 44.0)
        iconImage.contentMode = .scaleAspectFit
        iconImage.clipsToBounds = true
        
        let rightButton = UIBarButtonItem(customView: iconImage)
        self.navigationItem.rightBarButtonItem = rightButton

        
        let marginX : CGFloat = view.frame.width * 0.10
        let viewWidth : CGFloat = view.frame.width
        let textFieldHeight : CGFloat = 40
        
        let viñeta = "\u{2022} "
        let parte1 = conf?.translations?.data?.registro?.registerTyCFirst ?? "";
        let parte2 = conf?.translations?.data?.generales?.termsAndConditions ?? "";
        let parte3 = conf?.translations?.data?.registro?.registerTyCFinal ?? "";
        let strTerminosYCondiciones = String(format: "%@ <b>%@</b> %@", parte1, parte2, parte3);
       
        lblTilteView.text = (conf?.translations?.data?.digitalBirthTexts?.digitalBirthTitle) ?? ""
        lblTilteView.textColor = institutionalColors.claroBlackColor
        lblDesView.text = (conf?.translations?.data?.digitalBirthTexts?.digitalBirthDescription) ?? ""
        lblDesView.textColor = institutionalColors.claroTextColor
        
        txfName.selectedTitle = (conf?.translations?.data?.digitalBirthTexts?.digitalBirthName) ?? ""
        txfName.placeholder = (conf?.translations?.data?.digitalBirthTexts?.digitalBirthName) ?? ""
        txfName.title = (conf?.translations?.data?.digitalBirthTexts?.digitalBirthName) ?? ""
        txfName.hideQuestionMark()
        txfName.delegate = self;
        txfName.keyboardType = .asciiCapable
        txfName.autocorrectionType = .no
        txfName.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        validador?.registerField(txfName, rules: [RequiredRule(message: conf?.translations?.data?.generales?.emptyField ?? "")])
        
        txfEmail.selectedTitle = (conf?.translations?.data?.profile?.email) ?? ""
        txfEmail.placeholder = (conf?.translations?.data?.profile?.email) ?? ""
        txfEmail.title = (conf?.translations?.data?.profile?.email) ?? ""
        txfEmail.hideQuestionMark()
        txfEmail.delegate = self;
        txfEmail.keyboardType = .emailAddress
        txfEmail.autocorrectionType = .no
        txfEmail.autocapitalizationType = UITextAutocapitalizationType.none
        validador?.registerField(txfEmail, rules: [RequiredRule(message: conf?.translations?.data?.generales?.emptyField ?? ""), EmailRule(message: conf?.translations?.data?.generales?.emailErrorFormat ?? "")])
        
        txfPhone.selectedTitle = (conf?.translations?.data?.newRegisterTexts?.newRegisterCellphone) ?? ""
        txfPhone.placeholder = (conf?.translations?.data?.newRegisterTexts?.newRegisterCellphone) ?? ""
        txfPhone.title = (conf?.translations?.data?.newRegisterTexts?.newRegisterCellphone) ?? ""
        txfPhone.delegate = self;
        txfPhone.hideQuestionMark()
        txfPhone.keyboardType = .phonePad
        txfPhone.autocorrectionType = .no
        txfPhone.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        validador?.registerField(txfPhone, rules: [RequiredRule(message: conf?.translations?.data?.generales?.emptyField ?? "")])
        
        txfPassword.selectedTitle = conf?.translations?.data?.digitalBirthTexts?.digitalBirthPassword ?? "";
        txfPassword.placeholder =  conf?.translations?.data?.digitalBirthTexts?.digitalBirthPassword ?? "";
        txfPassword.title =  conf?.translations?.data?.digitalBirthTexts?.digitalBirthPassword ?? "";
        txfPassword.delegate = self;
        txfPassword.hideQuestionMark()
        txfPassword.isSecureTextEntry = true;
        txfPassword.setupSecurityEye()
        txfPassword.keyboardType = .asciiCapable
        txfPassword.autocorrectionType = .no
        txfPassword.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        validador?.registerField(txfPassword, rules: [RequiredRule(message: conf?.translations?.data?.generales?.emptyField ?? "")])
        
        txfConfirmPassword.selectedTitle = conf?.translations?.data?.digitalBirthTexts?.digitalBirthConfirmPassword ?? "";
        txfConfirmPassword.placeholder = conf?.translations?.data?.digitalBirthTexts?.digitalBirthConfirmPassword ?? "";
        txfConfirmPassword.title = conf?.translations?.data?.digitalBirthTexts?.digitalBirthConfirmPassword ?? "";
        txfConfirmPassword.delegate = self;
        txfConfirmPassword.hideQuestionMark()
        txfConfirmPassword.setupSecurityEye()
        txfConfirmPassword.isSecureTextEntry = true;
        txfConfirmPassword.keyboardType = .asciiCapable
        txfConfirmPassword.autocorrectionType = .no
        txfConfirmPassword.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        validador?.registerField(txfConfirmPassword, rules: [RequiredRule(message: conf?.translations?.data?.generales?.emptyField ?? "")])
        
        txtMandatoryName = MandatoryInformation(frame: CGRect(x: marginX + 40, y: txfName.frame.maxY, width: viewWidth - marginX*2 - 40, height: textFieldHeight/3))
        txtMandatoryName.backgroundColor = UIColor.clear
        scrollView.addSubview(txtMandatoryName)
        
        txtMandatoryEmail = MandatoryInformation(frame: CGRect(x: marginX + 40, y: txfEmail.frame.maxY, width: viewWidth - marginX*2 - 40, height: textFieldHeight/3))
        txtMandatoryEmail.backgroundColor = UIColor.clear
        scrollView.addSubview(txtMandatoryEmail)
        
        txtMandatoryPhone = MandatoryInformation(frame: CGRect(x: marginX + 40, y: txfPhone.frame.maxY, width: viewWidth - marginX*2 - 40, height: textFieldHeight/3))
        txtMandatoryPhone.backgroundColor = UIColor.clear
        scrollView.addSubview(txtMandatoryPhone)
        
        
        lbPasswordMustHave.text = conf?.translations?.data?.generales?.passwordMustHave ?? "Tu contraseña debe de ser:"
        lbPasswordMustHave.textColor = institutionalColors.claroTextColor
    
        lbPasswordRule1.textColor = institutionalColors.claroTextColor
        let passwordRule1 = conf?.translations?.data?.generales?.passwordRule1 ?? ""
        lbPasswordRule1.text = NSString(format: "%@ %@",viñeta, passwordRule1) as String
        
        lbPasswordRule2.textColor = institutionalColors.claroTextColor
        let passwordRule2 = conf?.translations?.data?.generales?.passwordRule2 ?? ""
        lbPasswordRule2.text = NSString(format: "%@ %@",viñeta, passwordRule2) as String
        
        lbPasswordRule3.textColor = institutionalColors.claroTextColor
        let passwordRule3 = conf?.translations?.data?.generales?.passwordRule3 ?? ""
        lbPasswordRule3.text = NSString(format: "%@ %@",viñeta, passwordRule3) as String
        
        // OCULTAR TERMINOS Y CONDICIONES
        self.txtMandatoryPass = MandatoryInformation(frame: CGRect(x: marginX + 40, y: self.txfPassword.frame.maxY, width: viewWidth - marginX*2 - 40, height: textFieldHeight/3))
        self.txtMandatoryPass.backgroundColor = UIColor.clear
        self.scrollView.addSubview(self.txtMandatoryPass)
        
        self.txtMandatoryConfirmPass = MandatoryInformation(frame: CGRect(x: marginX + 40, y: self.txfConfirmPassword.frame.maxY, width: viewWidth - marginX*2 - 40, height: textFieldHeight/3))
        self.txtMandatoryConfirmPass.backgroundColor = UIColor.clear
        self.scrollView.addSubview(self.txtMandatoryConfirmPass)
        
        self.lblTerminos = LinkableLabel();
        self.lblTerminos?.isEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.lnkTerminos_OnClick))
        self.lblTerminos?.frame = CGRect(x: 70, y: self.viewContainerDescriptionPass.frame.maxY, width: 220, height: 60)
        self.lblTerminos?.addGestureRecognizer(tap);
        self.lblTerminos?.showText(text: strTerminosYCondiciones);
        self.lblTerminos?.textAlignment = .left;
        self.lblTerminos?.font = UIFont(name: RobotoFontName.RobotoRegular.rawValue, size: CGFloat(14.0))
        self.lblTerminos?.numberOfLines = 0
        self.scrollView.addSubview(self.lblTerminos!);
        
        self.chkTerminos = SquaredCheckbox();
        self.chkTerminos?.frame = CGRect(x: 30, y: self.viewContainerDescriptionPass.frame.maxY, width: 35, height: 40)
        self.chkTerminos?.addTarget(self, action: #selector(self.chkValidate), for: UIControlEvents.touchUpInside)
        self.chkTerminos?.isEnabled = true
        self.chkTerminos?.isUserInteractionEnabled = true
        self.scrollView.addSubview(self.chkTerminos!)
        
        self.chkValidate()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public init() {
        super.init(nibName: nil, bundle: Bundle(for: CompleteRegisterDBViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        
        let actionType = mcaManagerSession.getActionType() ?? -1
        let infoUser = mcaManagerSession.getCurrentSession()
        
        if actionType == 1{
            self.txfName.enable()
            self.txfPhone.enable()
            self.txfEmail.enable()
            
            txfName.text = infoUser?.retrieveProfileInformationResponse?.personalDetailsInformation?.accountUserFirstName
            if(!(txfName.text?.isEmpty)!){
                self.txfName.disable()
            }
            txfPhone.text = infoUser?.retrieveProfileInformationResponse?.contactMethods?.first?.mobileContactMethodDetail?.mobileNumber
            if(!(txfPhone.text?.isEmpty)!){
                self.txfPhone.disable()
            }
            txfEmail.text = infoUser?.retrieveProfileInformationResponse?.contactMethods?.first?.emailContactMethodDetail?.emailAddress
            if(!(txfEmail.text?.isEmpty)!){
                self.txfEmail.disable()
            }
            
            if((txfName.text?.isEmpty)! || (txfEmail.text?.isEmpty)! || (txfPhone.text?.isEmpty)!){
                bUpDateProfile = true
            }
            
        }else if actionType == 2{
            
            self.txfName.disable()
            self.txfPhone.disable()
            self.txfEmail.disable()
            
            txfName.text = infoUser?.retrieveProfileInformationResponse?.personalDetailsInformation?.accountUserFirstName ?? UNAVAILABLE_TEXT
            txfPhone.text = infoUser?.retrieveProfileInformationResponse?.contactMethods?.first?.mobileContactMethodDetail?.mobileNumber ?? UNAVAILABLE_TEXT
            txfEmail.text = infoUser?.retrieveProfileInformationResponse?.contactMethods?.first?.emailContactMethodDetail?.emailAddress ?? UNAVAILABLE_TEXT
        }
    }
    
    func validationText() -> Bool {
        var isCorrect: Bool = true
        
        let txtString1 = txfName.text!
        let txtString2 = txfPassword.text!
        let txtString3 = txfConfirmPassword.text!
        let txtString4 = txfEmail.text!
        let txtString5 = txfPhone.text!
        
        if txtString1.isEmpty == false{
            if txtString4.isEmpty == false{
                if let count = txfEmail.text?.count, count > 0, let valid = txfEmail.text?.isValidEmail(), !valid {
                    if let _  = conf?.country?.userProfileIdConfig?.msgError {
                        let customError = (conf?.country?.userProfileIdConfig?.msgError)!
                        if  customError != ""{
                            txtMandatoryEmail.displayView(customString: customError)
                            isCorrect = false
                        }
                    }
                }
                else{
                    if txtString5.isEmpty == false{
                        let telefono = txfPhone.text?.trimmingCharacters(in: .whitespaces)
                        if "" != telefono, let count = telefono?.count, count >= 9 {
                            if txtString2.isEmpty == false{
                                if txtString3.isEmpty == false{
                                    let validateTxt2 = validate(pass: txtString2)
                                    let validateTxt3 = validate(pass: txtString3)
                                    if validateTxt3.hasError == false{
                                        if validateTxt2.hasError == false{
                                            if txtString2 == txtString3{
                                                //self.serviceUpdatePasswordEditProfile()
                                                isCorrect = true
                                            }else{
                                                txtMandatoryPass.displayView(customString: lbPasswordSameError)
                                                txtMandatoryConfirmPass.displayView(customString: lbPasswordSameError)
                                                isCorrect = false
                                            }
                                        }else{
                                            txtMandatoryPass.displayView(customString: validateTxt2.errorString)
                                            isCorrect = false
                                        }
                                    }else{
                                        txtMandatoryConfirmPass.displayView(customString: validateTxt3.errorString)
                                        isCorrect = false
                                    }
                                }else{
                                    txtMandatoryConfirmPass.displayView(customString: lbEmptyField)
                                    isCorrect = false
                                }
                            }else{
                                txtMandatoryPass.displayView(customString: lbEmptyField)
                                isCorrect = false
                            }
                        }
                        else if "" != telefono {
                            txtMandatoryPhone.displayView(customString: "nine-digits".localized)
                            isCorrect = false
                        }
                    }else{
                        txtMandatoryPhone.displayView(customString: lbEmptyField)
                        isCorrect = false
                    }
                }
            }else{
                txtMandatoryEmail.displayView(customString: lbEmptyField)
                isCorrect = false
            }
        }else{
            txtMandatoryName.displayView(customString: lbEmptyField)
            isCorrect = false
        }
        
        return isCorrect
    }
    
    //MARK: Action Button
    @IBAction func btnContinueAction(sender: UIButton) {
        let actionType = mcaManagerSession.getActionType() ?? -1
        
        if actionType == 1{
            if (bUpDateProfile){
                if self.validationText() {
                    self.serviceUpdateProfileInformation()
                }
            }else{
                self.serviceUpdatePassword()
            }
        }else if actionType == 2{
            if self.validationPass() {
                self.serviceUpdatePassword()
            }
        }
        
        let bienvenida = WelcomeCENAMVC()
        self.navigationController?.pushViewController(bienvenida, animated: true)
    }

    func validationPass() -> Bool {
        var isCorrect: Bool = true
        
        let txtString2 = txfPassword.text!
        let txtString3 = txfConfirmPassword.text!
    
        if txtString2.isEmpty == false{
            if txtString3.isEmpty == false{
                let validateTxt2 = validate(pass: txtString2)
                let validateTxt3 = validate(pass: txtString3)
                if validateTxt3.hasError == false{
                    if validateTxt2.hasError == false{
                        if txtString2 == txtString3{
                            isCorrect = true
                        }else{
                            txtMandatoryPass.displayView(customString: lbPasswordSameError)
                            txtMandatoryConfirmPass.displayView(customString: lbPasswordSameError)
                            isCorrect = false
                        }
                    }else{
                        txtMandatoryPass.displayView(customString: validateTxt2.errorString)
                        isCorrect = false
                    }
                }else{
                    txtMandatoryConfirmPass.displayView(customString: validateTxt3.errorString)
                    isCorrect = false
                }
            }else{
                txtMandatoryConfirmPass.displayView(customString: lbEmptyField)
                isCorrect = false
            }
        }else{
            txtMandatoryPass.displayView(customString: lbEmptyField)
            isCorrect = false
        }
        
        return isCorrect
    }
    
    @objc func lnkTerminos_OnClick() {
        if false == mcaManagerSession.isNetworkConnected() {
            mcaManagerSession.showOfflineMessage()
            return;
        }

        GeneralAlerts.showDataWebView(title: conf?.translations?.data?.generales?.termsAndConditions ?? "", url: conf?.termsAndConditions?.url ?? "", method: "GET", acceptTitle: conf?.translations?.data?.generales?.closeBtn ?? "", onAcceptEvent: {})
    }
    
    ///Valida el status de chkTerminos para poder habilitar o deshabilitar el btnSolicitar
    @objc func chkValidate(){
        if (true == chkTerminos!.isSelected) {
            self.btnContinue.isUserInteractionEnabled = true
//            self.btnContinue.isEnabled = true
            self.btnContinue.backgroundColor = institutionalColors.claroRedColor
            self.btnContinue.tintColor = institutionalColors.claroRedColor
            self.btnContinue.alpha = 1.0
        }else{
            self.btnContinue.isUserInteractionEnabled = false
//            self.btnContinue.isEnabled = false
            self.btnContinue.backgroundColor = institutionalColors.claroLightGrayColor
            self.btnContinue.tintColor = institutionalColors.claroRedColor
            self.btnContinue.alpha = 0.5
        }
    }
    
    /// función para validación del password
    /// - parameter pass: String
    func validate(pass : String) -> (hasError : Bool, errorString : String?){
        
        let numberRegEx  = ".*[0-9]+.*"
        let texttest1 = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let numberresult = texttest1.evaluate(with: pass)
        if !numberresult {
            return (true, lbPasswordRuleError)
        }
        
        let letterRegEx  = ".*[a-z]+.*"
        let texttest = NSPredicate(format:"SELF MATCHES %@", letterRegEx)
        let letterresult = texttest.evaluate(with: pass.lowercased())
        if !letterresult {
            return (true, lbPasswordRuleError)
        }
        
        let specialCharacterRegEx  = ".*[*^'-]+.*"
        let texttest2 = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
        let specialresult = texttest2.evaluate(with: pass)
        if specialresult {
            return (true, lbPasswordRuleError)
        }
        return (false, nil)
    }
    
    /// Función que permite determinar si el texto ingresado son caracteres validos y modifica / agrega / Elimina o no el caracter
    /// - parameter textField: campo de texto que se está editando
    /// - parameter range: Rango de los caracteres
    /// - parameter string: Cadena a anexar
    /// - Returns: Bool
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.count + string.count - range.length
        
        if textField != txfName{
            if string == " "{
                return false
            }
        }
        
        if textField.isKind(of: SkyFloatingLabelTextField.classForCoder()){
            if txfName == textField {
                
                if newLength == 0 {
                    txtMandatoryName.displayView()
                }
                else{
                    txtMandatoryName.hideView()
                }
                return newLength <= 60 // Bool
            }
            if txfPhone == textField {
                guard CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) else {
                    return false
                }
                if newLength == 0 {
                    txtMandatoryPhone.displayView()
                }
                else{
                    txtMandatoryPhone.hideView()
                }
                return newLength <= 9 // Bool
            }
            if txfPassword == textField {
                if newLength == 0 {
                    txtMandatoryPass.displayView()
                } else {
                    let str = textField.text! as NSString
                    let cad = str.replacingCharacters(in: range, with: string)
                    let validateResult = self.validate(pass: cad);
                    if validateResult.hasError == true {
                        txtMandatoryPass.displayView(customString: validateResult.errorString)
                    } else {
                        txtMandatoryPass.hideView()
                    }
                }
                return newLength <= 12 // Bool
            }
            if txfConfirmPassword == textField {
                if newLength == 0 {
                    txtMandatoryConfirmPass.displayView()
                } else {
                    let str = textField.text! as NSString
                    let cad = str.replacingCharacters(in: range, with: string)
                    let validateResult = self.validate(pass: cad);
                    if validateResult.hasError == true {
                        txtMandatoryConfirmPass.displayView(customString: validateResult.errorString)
                    }else {
                        txtMandatoryConfirmPass.hideView()
                    }
                }
                return newLength <= 12 // Bool
            }
        }
        return true
    }
    
    /// Función que permite determinar cuando un campo de texto ha iniciado su edición, se setea un tipo de teclado para esta vista
    /// - parameter textField: campo de texto que se está editando
    func textFieldDidBeginEditing(_ textField: UITextField) {        
        if txfName == textField {
            txtMandatoryName.hideView()
        }else if txfEmail == textField{
            txtMandatoryEmail.hideView()
        }else if txfPhone == textField{
            txtMandatoryPhone.hideView()
        }else if txfPassword == textField{
            txtMandatoryPass.hideView()
        }else if txfConfirmPassword == textField{
            txtMandatoryConfirmPass.hideView()
        }
        
    }
    
    /// Función que determina cuando un campo de texto ha finalizado su edición, muestra una alerta de aplicar
    /// - parameter textField: Campo en cuestión
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if txfName == textField {
            let txtString = txfName.text!
            if txtString.isEmpty {
               txtMandatoryName.displayView(customString: lbEmptyField)
            }
        }
        if txfEmail == textField {
            let txtString = txfEmail.text!
            if txtString.isEmpty {
                txtMandatoryEmail.displayView(customString: lbEmptyField)
            }else{
                if let count = textField.text?.count, count > 0, let valid = textField.text?.isValidEmail(), !valid {
                    if let _  = conf?.country?.userProfileIdConfig?.msgError {
                        let customError = (conf?.country?.userProfileIdConfig?.msgError)!
                        if  customError != ""{
                            txtMandatoryEmail.displayView(customString: customError)
                        }
                    }
                }
            }
        }
        if txfPhone == textField {
            let txtString = txfPhone.text!
            if txtString.isEmpty {
                txtMandatoryPhone.displayView(customString: lbEmptyField)
            }else{
                let telefono = txfPhone.text?.trimmingCharacters(in: .whitespaces);
                if "" != telefono, let count = telefono?.count, count >= 9 {
                }
                else if "" != telefono {
                    txtMandatoryPhone.displayView(customString: "nine-digits".localized)
                }
            }
        }
        if txfPassword == textField {
            let txtString = txfPassword.text!
            if txtString.isEmpty {
                txtMandatoryPass.displayView(customString: lbEmptyField)
            }
        }
        if txfConfirmPassword == textField {
            let txtString = txfConfirmPassword.text!
            if txtString.isEmpty {
                txtMandatoryConfirmPass.displayView(customString: lbEmptyField)
            }
        }
    }
    
    func updateUserInfoDataBase() {
        
        let service = mcaManagerSession.getLocalConfig()?.mcaConfigFile?.mobileFirstServerConfiguration?.mobileFirstCountryServices?[safe: 0]?.retrieveProfileInformation ?? ""
        
        let updateInfo = mcaManagerServer.getLastResponseFromService(service: service, ofType: RetrieveProfileInformationResult.self)
        
        updateInfo?.retrieveProfileInformationResponse?.personalDetailsInformation?.accountUserFirstName = txfName.text
        updateInfo?.retrieveProfileInformationResponse?.contactMethods?.first?.mobileContactMethodDetail?.mobileNumber = txfPhone.text
        updateInfo?.retrieveProfileInformationResponse?.contactMethods?.first?.emailContactMethodDetail?.emailAddress = txfEmail.text
        
        let save = mcaManagerServer.saveModel(response: updateInfo!,
                                              ofService: service)
        
        if save {
            print("SUCCESS UPDATE INFO IN DATABASE")
        }else {
            print("ERROR UPDATE INFO IN DATABASE")
        }
    }
    
    func serviceUpdateProfileInformation (){
        
        let valNewName = txfName.text
        let valMovil = txfPhone.text
        
        let infoUser = mcaManagerSession.getCurrentSession();
        let IdentificationNumber = infoUser?.retrieveProfileInformationResponse?.personalDetailsInformation?.rUT
        let rut = IdentificationNumber?.enmascararRut().maskedString
        let gender = infoUser?.retrieveProfileInformationResponse?.personalDetailsInformation?.accountUserGender
//        let myDate = (infoUser?.retrieveProfileInformationResponse?.personalDetailsInformation?.dateOfBirth)!
        
        //        print("Line Of Business sent \(lineOfBusiness.calculateLineOfBusiness())")
        let req = UpdateProfileInformationRequest()
        req.updateProfileInformation?.lineOfBusiness = "0" //lineOfBusiness.calculateLineOfBusiness();
        req.updateProfileInformation?.newUserProfileID = rut! //deberia de ser vacio
        
        req.updateProfileInformation?.isTermsAndConditionsAccepted = true
        req.updateProfileInformation?.isClaroPromotionsAccepted = true
        
        req.updateProfileInformation?.personalDetailsInformation = PersonalDetailsInformation()
        req.updateProfileInformation?.personalDetailsInformation?.accountUserFirstName = valNewName
        req.updateProfileInformation?.personalDetailsInformation?.accountUserLastName = ""
        req.updateProfileInformation?.personalDetailsInformation?.accountUserSecondLastName = ""
//      req.updateProfileInformation?.personalDetailsInformation?.dateOfBirth = myDate
        req.updateProfileInformation?.personalDetailsInformation?.isNotificationAuthorized = "true"
        req.updateProfileInformation?.personalDetailsInformation?.accountUserGender = gender!
//      req.updateProfileInformation?.personalDetailsInformation?.accountUserGender = "M"
        req.updateProfileInformation?.personalDetailsInformation?.city = "1"
        req.updateProfileInformation?.personalDetailsInformation?.accountUserTaxId = "19"
        req.updateProfileInformation?.personalDetailsInformation?.personalIdUpdate = PersonalId()
        req.updateProfileInformation?.personalDetailsInformation?.personalIdUpdate?.identificationType = "1"
        req.updateProfileInformation?.personalDetailsInformation?.personalIdUpdate?.identificationNumber = rut?.replacingOccurrences(of: "-", with: "")
        req.updateProfileInformation?.contactMethods = ContactMethod()
        req.updateProfileInformation?.contactMethods?.mobileContactMethodDetail = MobileContactMethodDetail()
        req.updateProfileInformation?.contactMethods?.mobileContactMethodDetail?.contactMethodId = "mobile"
        req.updateProfileInformation?.contactMethods?.mobileContactMethodDetail?.ispreferedContactMethod = true
        req.updateProfileInformation?.contactMethods?.mobileContactMethodDetail?.mobileNumber = valMovil
        
        mcaManagerServer.executeUpdateProfileInformation(params: req,
                                                               onSuccess: { (result) in
                                                                print(result);
                                                                print("serviceUpdateProfileInformation---------------- ok")
                                                                print("SUCCESS UPDATE PROFILE INFO")
                                                                GeneralAlerts.showAcceptOnly(title: self.conf?.translations?.data?.registro?.registerSuccessTitle ?? "", text: "info-updated".localized, icon: .IconoAlertaSMS, onAcceptEvent: {})
                                                                
                                                                //(result.0.updateProfileInformationResponse?.acknowledgementDescription)!
                                                                //"La información ha sido actualizada"
                                                            
                                                                self.updateUserInfoDataBase()
                                                                self.txfName.isEnabled = false;
                                                                self.txfPhone.isEnabled = false;
                                                                self.txfEmail.isEnabled = false;
                                                                self.txfPassword.isEnabled = false;
                                                                self.txfConfirmPassword.isEnabled = false;
                                                                self.btnContinue.isEnabled = false;
                                                                self.btnContinue.alpha = 0.5;
                                                    
                                                                self.serviceUpdatePassword()
        },
                                                               onFailure: { (result, myError) in
                                                                print("ERROR UPDATE PROFILE INFO")
                                                                GeneralAlerts.showAcceptOnly(text: result?.updateProfileInformationResponse?.acknowledgementDescription ?? "", icon: .IconoAlertaError, onAcceptEvent: {})
                                                                
                                                               
//                                                                accept.title = self.conf?.translations?.data?.registro?.registerSuccessTitle ?? ""
                                                        
//                                                                self.updateUserInfoDataBase()
//                                                                self.serviceProfileInformation()
        });
    }
    

    
    
    func serviceUpdatePassword() {
        
        let req = UpdatePasswordRequest();
        req.updatePassword?.userProfileId = mcaManagerSession.getCurrentSession()?.retrieveProfileInformationResponse?.personalDetailsInformation?.rUT//perQuestions?.validatePersonalVerificationQuestions?.userProfileId;
        req.updatePassword?.password = txfPassword?.text;
        req.updatePassword?.lineOfBusiness = "0"
        
        mcaManagerServer.executeUpdatePassword(params: req,
                                                     onSuccess: { (result) in
                                                        
                                                        let acknowledgementCodes = self.conf?.translations?.data?.acknowledgementCodes
                                                        
                                                        let actionType = mcaManagerSession.getActionType() ?? -1
                                                        var alertText = ""
                                                        var alertTitle = ""
                                                        var alertAcceptTitle = ""
                                                        var alertIcon: AlertIconType = .NoIcon
                                                        var alertBtnColor = institutionalColors.claroLightGrayColor
                                                        
                                                        if actionType == 1{
                                                            alertTitle = self.conf?.translations?.data?.passwordRecovery?.recoverySuccessTitle ?? ""
                                                            
                                                            for text in acknowledgementCodes! {
                                                                if text.aSSCMIDEMANUPDPROINFSC1 != nil {
                                                                    alertText = text.aSSCMIDEMANUPDPROINFSC1 ?? ""
                                                                }
                                                            }
//                                                          accept.text = (result.0.updatePasswordResponse?.acknowledgementDescription) ?? ""
                                                            alertAcceptTitle = self.conf?.translations?.data?.generales?.confirmBtn ?? ""
                                                            alertIcon = .IconoCuentaExitosa
                                                            alertBtnColor = institutionalColors.claroBlueColor
                                                            
                                                        }else if actionType == 2{
                                                             alertTitle = mcaManagerSession.getGeneralConfig()?.translations?.data?.registro?.registerSuccessTitle ?? ""
                                                            for text in acknowledgementCodes! {
                                                                if text.aSSCMIDEMANUPDPWDSC1 != nil {
                                                                    alertText = text.aSSCMIDEMANUPDPWDSC1 ?? ""
                                                                }
                                                            }
                                                            alertAcceptTitle = mcaManagerSession.getGeneralConfig()?.translations?.data?.generales?.closeBtn ?? ""
                                                            alertIcon = .IconoFelicidadesContraseñaCambiada
                                                            alertBtnColor = institutionalColors.claroBlueColor
                                                        }
                                                        
                                                        let onAcceptEvent = {
                                                            //Mostrar home
                                                            AnalyticsInteractionSingleton.sharedInstance.ADBTrackCustomLink(viewName: "Registro|Exito:Cerrar")
                                                            self.serviceProfileInformation()
                                                            
                                                            /*comentar estas lineas al final*/
                                                            if mcaManagerSession.getModeCompilation() == "DEBUG" {
//                                                                SessionSingleton.sharedInstance.setIsDigitalBirth(isDigital:true)
//                                                                SessionSingleton.sharedInstance.setActionType(type: 0)
//
//                                                                DispatchQueue.main.async(execute: {
//                                                                    UIApplication.shared.keyWindow?.rootViewController  = ContainerVC();
//                                                                })
                                                            }
                                                            /*comentar estas lineas al final*/
                                                        }
                                                        
                                                        GeneralAlerts.showAcceptOnly(title: alertTitle, text: alertText, icon: alertIcon, acceptTitle: alertAcceptTitle, acceptBtnColor: alertBtnColor, onAcceptEvent: onAcceptEvent)
                                                        
                                                        //self.automaticLogin()
                                                        AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Exito",type:7, detenido: false)
                                                        
                                                        
        },
                                                     onFailure: { (result, myError) in
                                                        /******************************************/
                                                        GeneralAlerts.showAcceptOnly(text: (result?.updatePasswordResponse?.acknowledgementDescription)!, icon: .IconoAlertaError, onAcceptEvent: {})
                                                        /******************************************/
        });
        
    }
    
    /// serviceProfileInformation: Obtiene la información del usuario
    /// - Parameter lineOfBusiness
    /// - Parameter userProfileId
    /// - Returns: SUCCESS - FAILURE
    func serviceProfileInformation(){
        
        let req = RetrieveProfileInformationRequest();
        req.retrieveProfileInformation?.lineOfBusiness = "0";
        let rut = mcaManagerSession.getCurrentSession()
        req.retrieveProfileInformation?.userProfileId = rut?.retrieveProfileInformationResponse?.personalDetailsInformation?.rUT
        
        mcaManagerServer.executeRetrieveProfileInformation(params: req,
                                                                 onSuccess: { (result) in
                                                                    print(result);
                                                                    /*NACIMIENTO DIGITAL*/ mcaManagerSession.setIsDigitalBirth(isDigital: result.0.retrieveProfileInformationResponse?.isDigitalBirth)
                                                                    mcaManagerSession.setActionType(type: result.0.retrieveProfileInformationResponse?.ActionType)
                                                                    /*NACIMIENTO DIGITAL*/
                                                                    
                                                                    //borrar estas lineas al final
                                                                    if mcaManagerSession.getModeCompilation() == "DEBUG" {
//                                                                        mcaManagerSession.setIsDigitalBirth(isDigital:true)
//                                                                        mcaManagerSession.setActionType(type: 0)
                                                                    }
                                                                    //borrar estas lineas al final
                                                                    
                                                                    DispatchQueue.main.async(execute: {
                                                                        self.didFinishRegister()
                                                                    })

        },
                                                                 onFailure: { (result, myError) in
                                                                    
                                                                    let acknowledgementCodes = self.conf?.translations?.data?.acknowledgementCodes
                                                                    
                                                                    for text in acknowledgementCodes! {
                                                                        if text.aSSCMACCMANRETASSACCBSERR2 != nil {
                                                                            if(result?.retrieveProfileInformationResponse?.acknowledgementCode == text.aSSCMACCMANRETASSACCBSERR2 ){
                                                                                mcaManagerSession.setCustomerWithoutServices(flag: true)
                                                                                DispatchQueue.main.async(execute: {
                                                                                    self.didFinishRegister()
                                                                                })
                                                                            }
                                                                        }
                                                                    }
                                                                    
                                                                    let onAcceptEvent = {
                                                                        mcaManagerSession.clearCacheData()
                                                                        NotificationCenter.default.post(name: NSNotification.Name(ObserverList.loadMainScreen.rawValue), object: self)
                                                                        mcaManagerSession.setCustomerWithoutServices(flag: false)
                                                                        AnalyticsInteractionSingleton.sharedInstance.cleanAccountArrays()
                                                                    }
                                                                
                                                                    GeneralAlerts.showAcceptOnly(title: "404-response-profile-information", icon: .IconoAlertaError,onAcceptEvent: onAcceptEvent)
                                                                    
        });
    }
    
}
