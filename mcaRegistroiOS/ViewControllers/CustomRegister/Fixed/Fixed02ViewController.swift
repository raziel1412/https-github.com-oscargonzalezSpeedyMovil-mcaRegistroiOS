//
//  Fixed02ViewController.swift
//  MiClaro
//
//  Created by Roberto Gutierrez Resendiz on 21/08/18.
//  Copyright © 2018 am. All rights reserved.
//

import UIKit
import SwiftValidator
import SkyFloatingLabelTextField
import mcaUtilsiOS
import mcaManageriOS

class Fixed02ViewController: UIViewController, UITextFieldDelegate, ValidationDelegate {
    
    var doLoginWhenFinish :((_ doAutomaticLogin: Bool) -> Void) = {_ in }
    
    @IBOutlet weak var imgRegistro: UIImageView!
    @IBOutlet weak var lblTituloRegistro: UILabel!
    @IBOutlet weak var lblSubtitulo1: UILabel!
    @IBOutlet weak var imgRUT: UIImageView!
    @IBOutlet weak var imgSerie: UIImageView!
    @IBOutlet weak var imgCorreo: UIImageView!

    @IBOutlet weak var txtRUT: SimpleGrayTextFieldQuestionMark!
    @IBOutlet weak var vwMandatoryRUT: MandatoryInformation!

    @IBOutlet weak var txtSerie: SimpleGrayTextFieldQuestionMark!
    @IBOutlet weak var vwMandatorySerie: MandatoryInformation!

    @IBOutlet weak var txtCorreo: SimpleGrayTextFieldQuestionMark!
    @IBOutlet weak var vwMandatoryCorreo: MandatoryInformation!

    @IBOutlet weak var cmdSiguiente: RedBorderWhiteBackgroundButton!

    private var conf = mcaManagerSession.getGeneralConfig()
    /// Objeto para validaciones
    private var validador : Validator?
    var RUT = ""

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
        lblTituloRegistro.text = conf?.translations?.data?.newRegisterTexts?.newRegisterTitle ?? ""

        lblSubtitulo1.font = UIFont(name: RobotoFontName.RobotoRegular.rawValue, size: CGFloat(16))
        lblSubtitulo1.numberOfLines = 0
        lblSubtitulo1.textAlignment = .center
        lblSubtitulo1.textColor = institutionalColors.claroTextColor
        lblSubtitulo1.text = conf?.translations?.data?.newRegisterTexts?.newRegisterFixedStep1 ?? ""
        lblSubtitulo1.sizeToFit();

        txtRUT.selectedTitle = conf?.translations?.data?.newRegisterTexts?.newRegisterUserProfileId ?? "";
        txtRUT.placeholder = conf?.translations?.data?.newRegisterTexts?.newRegisterUserProfileId ?? "";
        txtRUT.title = conf?.translations?.data?.newRegisterTexts?.newRegisterUserProfileId ?? "";
        txtRUT.hideQuestionMark()
        txtRUT.delegate = self;
        txtRUT.keyboardType = .asciiCapable
        txtRUT.autocorrectionType = .no
        txtRUT.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        validador?.registerField(txtRUT, rules: [RequiredRule(message: conf?.translations?.data?.generales?.emptyField ?? "")])
        txtRUT.isUserInteractionEnabled = false
        txtRUT.text = self.RUT

        txtSerie.action = creaDialog(titulo: conf?.translations?.data?.newRegisterTexts?.newRegisterSerialNumber ?? "");
        txtSerie.selectedTitle = conf?.translations?.data?.newRegisterTexts?.newRegisterSerialNumber ?? "";
        txtSerie.placeholder = conf?.translations?.data?.newRegisterTexts?.newRegisterSerialNumber ?? "";
        txtSerie.title = conf?.translations?.data?.newRegisterTexts?.newRegisterSerialNumber ?? "";
        txtSerie.delegate = self;
        txtSerie.keyboardType = .asciiCapable
        txtSerie.autocorrectionType = .no
        txtSerie.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        validador?.registerField(txtSerie, rules: [RequiredRule(message: conf?.translations?.data?.generales?.emptyField ?? "")])

        txtCorreo.selectedTitle = conf?.translations?.data?.generales?.email ?? "";
        txtCorreo.placeholder = conf?.translations?.data?.generales?.email ?? "";
        txtCorreo.title = conf?.translations?.data?.generales?.email ?? "";
        txtCorreo.hideQuestionMark()
        txtCorreo.delegate = self;
        txtCorreo.keyboardType = .emailAddress
        txtCorreo.autocorrectionType = .no
        txtCorreo.autocapitalizationType = UITextAutocapitalizationType.none
        validador?.registerField(txtCorreo, rules: [RequiredRule(message: conf?.translations?.data?.generales?.emptyField ?? ""), EmailRule(message: conf?.translations?.data?.generales?.emailErrorFormat ?? "")])

        cmdSiguiente.setTitle(conf?.translations?.data?.generales?.confirmBtn, for: UIControlState.normal);
        cmdSiguiente.setTitle(conf?.translations?.data?.generales?.confirmBtn, for: UIControlState.selected);

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func cmdSiguiente_OnClick(_ sender: RedBorderWhiteBackgroundButton) {
        print(String(format: "%@ Ejecuta Siguiente", String(describing: Fixed02ViewController.self)));
        if(txtRUT.isFirstResponder) {
            txtRUT.resignFirstResponder();
        } else if(txtSerie.isFirstResponder) {
            txtSerie.resignFirstResponder();
        } else if(txtCorreo.isFirstResponder) {
            txtCorreo.resignFirstResponder();
        }
        
        self.validador?.validate(self);
    }

    /// Función que evalua si todo esta correcto y realiza la llamada al Servicio Web
    func validationSuccessful() {
        AnalyticsInteractionSingleton.sharedInstance.ADBTrackCustomLink(viewName: "Registro|Paso 1|Ingresar datos:Continuar")

        let validateRequest = ValidateRUTRequest()
        validateRequest.validateRUT?.lineOfBusiness = "1"
        validateRequest.validateRUT?.rut = self.RUT
        validateRequest.validateRUT?.serialDocument = self.txtSerie.text
        mcaManagerServer.executeValidateRUT(params: validateRequest, onSuccess: {(result, resultType) in
            
            let prepaid5 = PrepaidRegisterStep5VC()
            prepaid5.RUT = self.RUT
            prepaid5.accountID = self.txtSerie.text ?? ""
            prepaid5.email = self.txtCorreo.text ?? ""
            prepaid5.lineOfBussines = TypeLineOfBussines.Fijo
            prepaid5.doLoginWhenFinish = self.doLoginWhenFinish
            self.navigationController?.pushViewController(prepaid5, animated: true)
            
        }, onFailure: {(result, error) in
            GeneralAlerts.showAcceptOnly(text: result?.validateRUTResponse?.acknowledgementDescription ?? "", icon: AlertIconType.IconoAlertaError, onAcceptEvent: {})
        })
    }

    /// Función encargada de notificar si existe algún campo con datos inválidos
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        vwMandatoryRUT.hideView();
        vwMandatorySerie.hideView();
        vwMandatoryCorreo.hideView()
        errors.forEach({ error in
            print(error)
            let currentField = error.1.field as? SimpleGrayTextFieldQuestionMark;
            if txtRUT == currentField {
                vwMandatoryRUT.hideView();
                let mask = currentField?.text?.enmascararRut()
                if let strError = mask?.errorString {
                    vwMandatoryRUT.displayView(customString: strError.count > 0 ? strError : currentField?.validationText)
                    AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 2|Ingresar datos|Detenido",type:1, detenido: true, mensaje:"Campo obligatorio")
                }
            } else if txtSerie == currentField {
                vwMandatorySerie.hideView();
                vwMandatorySerie.displayView(customString: error.1.errorMessage)
                AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 2|Ingresar datos|Detenido",type:1, detenido: true, mensaje:"Campo obligatorio")
            } else if txtCorreo == currentField {
                vwMandatoryCorreo.hideView()
                if let valid = currentField?.text?.isValidEmail(), !valid {
                    vwMandatoryCorreo.displayView(customString: error.1.errorMessage)
                    AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 2|Ingresar datos|Detenido",type:1, detenido: true, mensaje:"Campo obligatorio")
                }
            }
        })
    }

    /// Función que crear una alerta, con un texto predefinido
    /// - parameter titulo: Texto del título
    /// - Return: Void, Void
    func creaDialog(titulo : String?) -> (() -> ()) {
        return {
            var bounds : CGRect = .zero
            if let _ = UIApplication.shared.keyWindow?.bounds {
                bounds = (UIApplication.shared.keyWindow?.bounds)!
            } else {
                bounds = self.view.bounds
            }

            let backgroundView = UIView(frame: bounds)
            backgroundView.backgroundColor = institutionalColors.claroBlackColor
            backgroundView.alpha = 0.56
            backgroundView.tag = -901
            UIApplication.shared.keyWindow?.addSubview(backgroundView)
            //self.view.addSubview(backgroundView)

            let toolTipGroup : ToolTipGroup = ToolTipGroup(frame: CGRect(x: 0.04 * bounds.size.width, y: 0.12 * bounds.size.height, width: 0.92 * bounds.size.width, height: 0.75 * bounds.size.height))
            toolTipGroup.setHeaderContent(title: self.conf?.translations?.data?.registro?.tooltipTitle, subtitle: self.conf?.translations?.data?.registro?.tooltipDescription, imageName: "ico_numero_de_serie")
            toolTipGroup.setLeftItemContent(title: self.conf?.translations?.data?.registro?.tooltipOld, subtitle: self.conf?.translations?.data?.registro?.tooltipOldText, imageName: "RUT_Viejo")
            toolTipGroup.setRightItemContent(title: self.conf?.translations?.data?.registro?.tooltipNew, subtitle: self.conf?.translations?.data?.registro?.tooltipNewText, imageName: "RUT_Nuevo")
            toolTipGroup.setButtonContent(title: self.conf?.translations?.data?.generales?.closeBtn, target: self, action: #selector(self.closeToolTip(_:)), controlEvent: .touchUpInside)
            toolTipGroup.tag = -901

            if self.view.frame.size.height == 504.0 {
                toolTipGroup.haderSubtitleFont = UIFont(name: RobotoFontName.RobotoRegular.rawValue, size: CGFloat(13))!
                toolTipGroup.tipElementSubtitleFont = UIFont(name: RobotoFontName.RobotoRegular.rawValue, size: CGFloat(11))!
            }
            toolTipGroup.center =  (UIApplication.shared.keyWindow?.center)!
            toolTipGroup.alpha = 0.0
            UIApplication.shared.keyWindow?.addSubview(toolTipGroup)
            UIView.animate(withDuration: 0.4, animations: {
                toolTipGroup.alpha = 1.0
            })
        };
    }

    @objc func closeToolTip(_ sender: Any) {
        UIApplication.shared.keyWindow?.subviews.forEach({
            if $0.tag == -901 {
                let view = $0
                UIView.animate(withDuration: 0.2, animations: {
                    view.alpha = 0.0
                }, completion: { (completed) in
                    view.removeFromSuperview()
                })
            }
        })
    }

    /// Función que permite determinar cuando un campo de texto ha iniciado su edición, se setea un tipo de teclado para esta vista
    /// - parameter textField: campo de texto que se está editando
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.keyboardType = .asciiCapable
        if let currentText = textField.text, let separator = mcaManagerSession.getGeneralConfig()?.country?.userProfileIdConfig?.separador {
            textField.text = currentText.replacingOccurrences(of: separator, with: "")
        }
    }

    /// Función que permite determinar si el texto ingresado son caracteres validos y modifica / agrega / Elimina o no el caracter
    /// - parameter textField: campo de texto que se está editando
    /// - parameter range: Rango de los caracteres
    /// - parameter string: Cadena a anexar
    /// - Returns: Bool
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let lenght = (mcaManagerSession.getGeneralConfig()?.country?.userProfileIdConfig?.max)! - 1 //10
        if textField == txtRUT {//RUT
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string) as String
            let nsString = NSString(string: newString)
            return !(nsString.length > lenght)
        }

        return true
    }

    /// Función que determina cuando un campo de texto ha finalizado su edición, muestra una alerta de aplicar
    /// - parameter textField: Campo en cuestión
    func textFieldDidEndEditing(_ textField: UITextField) {
        if txtRUT == textField {
            vwMandatoryRUT.hideView();
            let mask = txtRUT?.text?.enmascararRut()
            txtRUT.text = mask?.maskedString;
            if let strError = mask?.errorString {
                vwMandatoryRUT.displayView(customString: strError.count > 0 ? strError : conf?.translations?.data?.generales?.emptyField)
            }
        } else if txtSerie == textField {
            vwMandatorySerie.hideView();
            if let correo = txtSerie.text, (correo.count < 1) {
                vwMandatorySerie.displayView(customString: conf?.translations?.data?.generales?.emptyField ?? "")
            }
        } else if txtCorreo == textField {
            vwMandatoryCorreo.hideView();
            if let correo = txtCorreo.text, (correo.count < 1) {
                vwMandatoryCorreo.displayView(customString: conf?.translations?.data?.generales?.emptyField ?? "")
                return;
            }
            if let valid = txtCorreo.text?.isValidEmail(), !valid {
                vwMandatoryCorreo.displayView(customString: conf?.translations?.data?.generales?.emailErrorFormat)
            }
        }
    }
}
