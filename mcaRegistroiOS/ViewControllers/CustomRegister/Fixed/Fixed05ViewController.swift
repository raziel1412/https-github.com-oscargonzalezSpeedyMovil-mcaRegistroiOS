//
//  Fixed05ViewController.swift
//  MiClaro
//
//  Created by Roberto Gutierrez Resendiz on 21/08/18.
//  Copyright © 2018 am. All rights reserved.
//

import UIKit
import SwiftValidator
import mcaUtilsiOS
import mcaManageriOS

class Fixed05ViewController: UIViewController, UITextFieldDelegate, ValidationDelegate {
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var imgRegistro: UIImageView!
    @IBOutlet weak var lblTituloRegistro: UILabel!
    @IBOutlet weak var lblSubtituloRegistro: UILabel!

    @IBOutlet weak var txtNombre: SimpleGrayTextFieldQuestionMark!
    @IBOutlet weak var vwMandatoryNombre: MandatoryInformation!

    @IBOutlet weak var txtCorreo: SimpleGrayTextFieldQuestionMark!
    @IBOutlet weak var vwMandatoryCorreo: MandatoryInformation!

    @IBOutlet weak var txtTelefono: SimpleGrayTextFieldQuestionMark!
    @IBOutlet weak var lblCodigoPais: UILabel!
    @IBOutlet weak var vwMandatoryTelefono: MandatoryInformation!

    @IBOutlet weak var txtPassword: SimpleGrayTextFieldQuestionMark!
    @IBOutlet weak var vwMandatoryPassword: MandatoryInformation!

    @IBOutlet weak var txtPasswordConfirm: SimpleGrayTextFieldQuestionMark!
    @IBOutlet weak var vwMandatoryPasswordConfirm: MandatoryInformation!

    @IBOutlet weak var lblInfoPassword1: UILabel!
    @IBOutlet weak var lblInfoPassword2: UILabel!
    @IBOutlet weak var lblInfoPassword3: UILabel!
    @IBOutlet weak var lblInfoPassword4: UILabel!

    @IBOutlet weak var cmdSiguiente: RedBorderWhiteBackgroundButton!
    private var conf = mcaManagerSession.getGeneralConfig()
    /// Objeto para validaciones
    private var validador : Validator?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = institutionalColors.claroWhiteColor
        self.initWith(navigationType:.IconBack, headerTitle: conf?.translations?.data?.registro?.header ?? "")

        validador = Validator()
        if UIScreen.main.bounds.width == 320{
            lblTituloRegistro.font = UIFont(name: RobotoFontName.RobotoRegular.rawValue, size: CGFloat(16))
        }else{
            lblTituloRegistro.font = UIFont(name: RobotoFontName.RobotoRegular.rawValue, size: CGFloat(20))
        }
        lblTituloRegistro.textAlignment = .center
        lblTituloRegistro.textColor = institutionalColors.claroBlackColor
        lblTituloRegistro.text = conf?.translations?.data?.newRegisterTexts?.newRegisterLastStepTitle ?? ""

        lblSubtituloRegistro.font = UIFont(name: RobotoFontName.RobotoRegular.rawValue, size: CGFloat(16))
        lblSubtituloRegistro.textAlignment = .center
        lblSubtituloRegistro.textColor = institutionalColors.claroTextColor
        lblSubtituloRegistro.text = conf?.translations?.data?.newRegisterTexts?.newRegisterLastStepDescription ?? ""

        txtNombre.selectedTitle = conf?.translations?.data?.newRegisterTexts?.newRegisterName ?? "";
        txtNombre.placeholder = conf?.translations?.data?.newRegisterTexts?.newRegisterName ?? "";
        txtNombre.title = conf?.translations?.data?.newRegisterTexts?.newRegisterName ?? "";
        txtNombre.hideQuestionMark()
        txtNombre.delegate = self;
        txtNombre.keyboardType = .asciiCapable
        txtNombre.autocorrectionType = .no
        txtNombre.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        validador?.registerField(txtNombre, rules: [RequiredRule(message: conf?.translations?.data?.generales?.emptyField ?? "")])

        txtCorreo.selectedTitle = conf?.translations?.data?.generales?.email ?? "";
        txtCorreo.placeholder = conf?.translations?.data?.generales?.email ?? "";
        txtCorreo.title = conf?.translations?.data?.generales?.email ?? "";
        txtCorreo.hideQuestionMark()
        txtCorreo.delegate = self;
        txtCorreo.keyboardType = .emailAddress
        txtCorreo.autocorrectionType = .no
        txtCorreo.autocapitalizationType = UITextAutocapitalizationType.none
        validador?.registerField(txtCorreo, rules: [RequiredRule(message: conf?.translations?.data?.generales?.emptyField ?? ""), EmailRule(message: conf?.translations?.data?.generales?.emailErrorFormat ?? "")])

        lblCodigoPais.font = UIFont(name: RobotoFontName.RobotoRegular.rawValue, size: CGFloat(16))
        lblCodigoPais.textAlignment = .center
        lblCodigoPais.textColor = institutionalColors.claroTextColor
        lblCodigoPais.text = mcaManagerSession.getGeneralConfig()?.country?.phoneCountryCode ?? ""

        txtTelefono.selectedTitle = conf?.translations?.data?.newRegisterTexts?.newRegisterCellphone ?? "";
        txtTelefono.placeholder = conf?.translations?.data?.newRegisterTexts?.newRegisterCellphone ?? "";
        txtTelefono.title = conf?.translations?.data?.newRegisterTexts?.newRegisterCellphone ?? "";
        txtTelefono.delegate = self;
        txtTelefono.hideQuestionMark()
        txtTelefono.keyboardType = .phonePad
        txtTelefono.autocorrectionType = .no
        txtTelefono.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        validador?.registerField(txtTelefono, rules: [RequiredRule(message: conf?.translations?.data?.generales?.emptyField ?? "")])

        txtPassword.selectedTitle = conf?.translations?.data?.newRegisterTexts?.newRegisterPassword ?? "";
        txtPassword.placeholder = conf?.translations?.data?.newRegisterTexts?.newRegisterPassword ?? "";
        txtPassword.title = conf?.translations?.data?.newRegisterTexts?.newRegisterPassword ?? "";
        txtPassword.delegate = self;
        txtPassword.hideQuestionMark()
        txtPassword.isSecureTextEntry = true;
        txtPassword.setupSecurityEye()
        txtPassword.keyboardType = .asciiCapable
        txtPassword.autocorrectionType = .no
        txtPassword.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        validador?.registerField(txtPassword, rules: [RequiredRule(message: conf?.translations?.data?.generales?.emptyField ?? "")])

        txtPasswordConfirm.selectedTitle = conf?.translations?.data?.newRegisterTexts?.newRegisterConfirmPassword ?? "";
        txtPasswordConfirm.placeholder = conf?.translations?.data?.newRegisterTexts?.newRegisterConfirmPassword ?? "";
        txtPasswordConfirm.title = conf?.translations?.data?.newRegisterTexts?.newRegisterConfirmPassword ?? "";
        txtPasswordConfirm.delegate = self;
        txtPasswordConfirm.hideQuestionMark()
        txtPasswordConfirm.setupSecurityEye()
        txtPasswordConfirm.isSecureTextEntry = true;
        txtPasswordConfirm.keyboardType = .asciiCapable
        txtPasswordConfirm.autocorrectionType = .no
        txtPasswordConfirm.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        validador?.registerField(txtPasswordConfirm, rules: [ConfirmationRule(confirmField: txtPassword, message: conf?.translations?.data?.generales?.passwordSameError ?? ""),
                                                             RequiredRule(message: conf?.translations?.data?.generales?.emptyField ?? "")])

        lblInfoPassword1.text = conf?.translations?.data?.generales?.passwordMustHave ?? "";
        lblInfoPassword1.lineBreakMode = .byWordWrapping
        lblInfoPassword1.numberOfLines = 0;
        lblInfoPassword1.font = UIFont(name: RobotoFontName.RobotoRegular.rawValue, size: CGFloat(12))!;
        lblInfoPassword1.textColor = institutionalColors.claroMenuLightGray

        lblInfoPassword2.text = conf?.translations?.data?.generales?.passwordRule1 ?? "";
        lblInfoPassword2.lineBreakMode = .byWordWrapping
        lblInfoPassword2.numberOfLines = 0;
        lblInfoPassword2.font = UIFont(name: RobotoFontName.RobotoRegular.rawValue, size: CGFloat(12))!;
        lblInfoPassword2.textColor = institutionalColors.claroMenuLightGray

        lblInfoPassword3.text = conf?.translations?.data?.generales?.passwordRule2 ?? "";
        lblInfoPassword3.lineBreakMode = .byWordWrapping
        lblInfoPassword3.numberOfLines = 0;
        lblInfoPassword3.font = UIFont(name: RobotoFontName.RobotoRegular.rawValue, size: CGFloat(12))!;
        lblInfoPassword3.textColor = institutionalColors.claroMenuLightGray

        lblInfoPassword4.text = conf?.translations?.data?.generales?.passwordRule3 ?? "";
        lblInfoPassword4.lineBreakMode = .byWordWrapping
        lblInfoPassword4.numberOfLines = 0;
        lblInfoPassword4.font = UIFont(name: RobotoFontName.RobotoRegular.rawValue, size: CGFloat(12))!;
        lblInfoPassword4.textColor = institutionalColors.claroMenuLightGray

        cmdSiguiente.setTitle(conf?.translations?.data?.generales?.confirmBtn, for: UIControlState.normal);
        cmdSiguiente.setTitle(conf?.translations?.data?.generales?.confirmBtn, for: UIControlState.selected);

        DispatchQueue.main.async {
            self.myScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: self.cmdSiguiente.frame.maxY + 15);
            self.myScrollView.bounces = false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cmdSiguiente_OnClick(_ sender: UIButton) {
        print(String(format: "%@ Ejecuta Siguiente", String(describing: Fixed05ViewController.self)));
        if(txtNombre.isFirstResponder) {
            txtNombre.resignFirstResponder();
        } else if(txtCorreo.isFirstResponder) {
            txtCorreo.resignFirstResponder();
        } else if(txtTelefono.isFirstResponder) {
            txtTelefono.resignFirstResponder();
        } else if(txtPassword.isFirstResponder) {
            txtPassword.resignFirstResponder();
        } else if(txtPasswordConfirm.resignFirstResponder()) {
            txtPasswordConfirm.resignFirstResponder()
        }
        self.validador?.validate(self);
    }

    func validationSuccessful() {
        AnalyticsInteractionSingleton.sharedInstance.ADBTrackCustomLink(viewName: "Registro|Paso 5|Ingresar datos:Continuar")

        GeneralAlerts.showAcceptOnly(title: conf?.translations?.data?.generales?.pinAlertTitle ?? "", text: conf?.translations?.data?.newRegisterTexts?.newRegisterSuccessText ?? "", icon: .IconoCodigoDeVerificacionDeTexto, onAcceptEvent: {})
    }

    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        vwMandatoryNombre.hideView();
        vwMandatoryCorreo.hideView();
        vwMandatoryTelefono.hideView();
        vwMandatoryPassword.hideView();
        vwMandatoryPasswordConfirm.hideView();

        errors.forEach({ error in
            print(error)
            let currentField = error.1.field as? SimpleGrayTextFieldQuestionMark;
            if txtNombre == currentField {
                vwMandatoryNombre.hideView();
                if let texto = txtNombre.text, texto.count < 1 {
                    vwMandatoryNombre.displayView(customString: currentField?.validationText)
                    AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 5|Ingresar datos|Detenido",type:1, detenido: true, mensaje:"Campo obligatorio")
                }
            } else if txtCorreo == currentField {
                vwMandatoryCorreo.hideView()
                if let valid = currentField?.text?.isValidEmail(), !valid {
                    vwMandatoryCorreo.displayView(customString: error.1.errorMessage)
                    AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 5|Ingresar datos|Detenido",type:1, detenido: true, mensaje:"Campo obligatorio")
                }
            } else if txtTelefono == currentField {
                vwMandatoryTelefono.hideView();
                vwMandatoryTelefono.displayView(customString: error.1.errorMessage)
                AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 5|Ingresar datos|Detenido",type:1, detenido: true, mensaje:"Campo obligatorio")
            } else if txtPassword == currentField {
                vwMandatoryPassword.hideView();
                vwMandatoryPassword.displayView(customString: error.1.errorMessage)
                AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 5|Ingresar datos|Detenido",type:1, detenido: true, mensaje:"Campo obligatorio")
            } else if txtPasswordConfirm == currentField {
                vwMandatoryPasswordConfirm.hideView();
                vwMandatoryPasswordConfirm.displayView(customString: error.1.errorMessage)
                AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 5|Ingresar datos|Detenido",type:1, detenido: true, mensaje:"Campo obligatorio")
            }
        })
    }

    /// Función que permite determinar cuando un campo de texto ha iniciado su edición, se setea un tipo de teclado para esta vista
    /// - parameter textField: campo de texto que se está editando
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.keyboardType = .asciiCapable
        if (txtNombre == textField) {
            vwMandatoryNombre.hideView();
        } else if (txtCorreo == textField) {
            vwMandatoryCorreo.hideView();
        } else if (txtTelefono == textField) {
            vwMandatoryTelefono.hideView();
        } else if (txtPassword == textField) {
            vwMandatoryPassword.hideView();
        } else if (txtPasswordConfirm == textField) {
            vwMandatoryPasswordConfirm.hideView();
        }
    }

    /// Función que determina cuando un campo de texto ha finalizado su edición, muestra una alerta de aplicar
    /// - parameter textField: Campo en cuestión
    func textFieldDidEndEditing(_ textField: UITextField) {
        if txtNombre == textField {
            vwMandatoryNombre.hideView();
            let nombre = txtNombre.text ?? "";
            if nombre.count < 1 {
                vwMandatoryNombre.displayView(customString: conf?.translations?.data?.generales?.emptyField ?? "")
            }
        } else if txtCorreo == textField {
            vwMandatoryCorreo.hideView();
            if let correo = txtCorreo.text, (correo.count < 1) {
                vwMandatoryCorreo.displayView(customString: conf?.translations?.data?.generales?.emptyField ?? "")
                return;
            }
            if let correo = txtCorreo.text, !correo.isValidEmail() {
                vwMandatoryCorreo.displayView(customString: conf?.translations?.data?.generales?.emailErrorFormat ?? "")
                return;
            }
        } else if txtTelefono == textField {
            vwMandatoryTelefono.hideView();
            if let correo = txtTelefono.text, (correo.count < 1) {
                vwMandatoryTelefono.displayView(customString: conf?.translations?.data?.generales?.emptyField ?? "")
                return;
            }
        } else if txtPassword == textField {
            vwMandatoryPassword.hideView();
            if let psw = txtPassword.text, (psw.count < 1) {
                vwMandatoryPassword.displayView(customString: conf?.translations?.data?.generales?.emptyField ?? "")
                return;
            }

            if txtPassword.text != txtPasswordConfirm.text && (txtPasswordConfirm.text?.count ?? 0) > 0 {
                vwMandatoryPassword.displayView(customString: conf?.translations?.data?.generales?.passwordSameError ?? "")
            }
        } else if txtPasswordConfirm == textField {
            vwMandatoryPasswordConfirm.hideView();
            if let psw = txtPasswordConfirm.text, (psw.count < 1) {
                vwMandatoryPasswordConfirm.displayView(customString: conf?.translations?.data?.generales?.emptyField ?? "")
                return;
            }
            if txtPassword.text != txtPasswordConfirm.text && (txtPassword.text?.count ?? 0) > 0 {
                vwMandatoryPasswordConfirm.displayView(customString: conf?.translations?.data?.generales?.passwordSameError ?? "")
            }
        }
    }

}
