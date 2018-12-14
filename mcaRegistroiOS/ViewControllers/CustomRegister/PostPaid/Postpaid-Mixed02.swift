    //
//  Postpaid-Mixed02.swift
//  MiClaro
//
//  Created by Omar Israel Trujillo Osornio on 16/08/18.
//  Copyright © 2018 am. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import mcaManageriOS
import mcaUtilsiOS

class Postpaid_Mixed02: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    
    var doLoginWhenFinish :((_ doAutomaticLogin: Bool) -> Void) = {_ in }
    
    ///Clase que construye el header del controller
    private var header : UIHeaderForm = UIHeaderForm(frame: .zero)
    ///Textfield para la contraseña actual
    var txtUser: SimpleGrayTextField!
    var imgRut = UIImageView()
    var txtPhone : SimpleGrayTextField!
    var imgPhone = UIImageView()
    var txtUserMandatory : MandatoryInformation!
    var txtPhoneMandatory : MandatoryInformation!
    var lbEmptyField = String()
    private var conf : GeneralConfig?;
    var scrollView = UIScrollView()
    var rut = String()
    // MARK: - ViewControlelr Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupUI(){
        
        self.view.backgroundColor = institutionalColors.claroWhiteColor
        self.initWith(navigationType:.IconBack, headerTitle: conf?.translations?.data?.registro?.header ?? "")
        //let viñeta = "\u{2022}"
        let marginX : CGFloat = 30.0//view.frame.width * 0.10
        let viewWidth : CGFloat = view.frame.width
        let textFieldHeight : CGFloat = 40
        conf = mcaManagerSession.getGeneralConfig()

        //ScrollView para ajuste de iPhone 5
        scrollView.backgroundColor = UIColor .clear
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isScrollEnabled = true
        self.view.addSubview(scrollView)
        
        //Encabezado
        let title = conf?.translations?.data?.newRegisterTexts?.newRegisterTitle ?? ""
        let subTitle = conf?.translations?.data?.newRegisterTexts?.newRegisterDescriptionStep1 ?? ""
        let lbTxtRut = conf?.translations?.data?.newRegisterTexts?.newRegisterUserProfileId ?? ""
        let lbTxtPhone = conf?.translations?.data?.newRegisterTexts?.newRegisterCellphone ?? ""
        
        header.setupElements(imageName: "ico_seccion_registro", title: title, subTitle: subTitle )
        header.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 200.0)
        self.scrollView.addSubview(header)
        
        txtUser = SimpleGrayTextField(text: lbTxtRut, placeholder: rut)
        txtUser.isEnabled = true
        txtUser.isHighlighted = true
        

        txtUser.frame = CGRect(x: marginX + 40, y: header.frame.maxY + 15, width: viewWidth - marginX*2 - 40, height: textFieldHeight)
        txtUser.delegate = self
        txtUser.tag = 1
        txtUser.backgroundColor = UIColor.clear
        txtUser.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        txtUser.keyboardType = .default
        txtUser.isSecureTextEntry = false
        txtUser.isUserInteractionEnabled = false
        txtUser.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        txtUser.addTarget(self, action: #selector(textFieldDidBeginEditing(_:)), for: .editingDidBegin)
        if viewWidth == 320 {
            txtUser.customFont = UIFont(name: RobotoFontName.RobotoRegular.rawValue, size: CGFloat(12))!
        }
        txtUserMandatory = MandatoryInformation(frame: CGRect(x: marginX + 40, y: txtUser.frame.maxY, width: viewWidth - marginX*2 - 40, height: textFieldHeight/2))
        txtUserMandatory.backgroundColor = UIColor.clear
        
        self.scrollView.addSubview(txtUserMandatory)
        self.scrollView.addSubview(txtUser)
        
        imgRut = UIImageView(frame: CGRect(x: marginX, y: txtUser.frame.maxY - 30, width: 30.0, height: 30.0))
        imgRut.image = #imageLiteral(resourceName: "icon_rut_input")
        imgRut.backgroundColor = UIColor.clear
        self.scrollView.addSubview(imgRut)
        
    
        txtPhone = SimpleGrayTextField(text: lbTxtPhone, placeholder: lbTxtPhone)
        txtPhone.frame = CGRect(x: 110, y: txtUser.frame.maxY + 15, width: viewWidth - marginX*2 - 80, height: textFieldHeight)
        txtPhone.delegate = self
        txtPhone.tag = 1
        txtPhone.backgroundColor = UIColor.clear
        txtPhone.autocapitalizationType = UITextAutocapitalizationType.none
        txtPhone.isSecureTextEntry = false
        if viewWidth == 320 {
            txtPhone.customFont = UIFont(name: RobotoFontName.RobotoRegular.rawValue, size: CGFloat(12))!
        }
        txtPhoneMandatory = MandatoryInformation(frame: CGRect(x: 110, y: txtPhone.frame.maxY, width: viewWidth - marginX*2 - 40, height: textFieldHeight/2))
        txtPhoneMandatory.backgroundColor = UIColor.clear
        
        self.scrollView.addSubview(txtPhoneMandatory)
        self.scrollView.addSubview(txtPhone)
        
        imgPhone = UIImageView(frame: CGRect(x: marginX, y: txtPhone.frame.maxY - 30, width: 30.0, height: 30.0))
        imgPhone.image = #imageLiteral(resourceName: "icon_telefono_input")
        imgPhone.backgroundColor = UIColor.clear
        
        let codigoPais = (conf?.country?.phoneCountryCode ?? "").digitsOnly
        let lbCodecontry = UILabel()
        lbCodecontry.frame = CGRect(x: imgPhone.frame.maxX + 5, y: txtUser.frame.maxY + 20, width: 60, height: textFieldHeight)
        lbCodecontry.backgroundColor = UIColor .clear
        lbCodecontry.textColor = institutionalColors.claroBlackColor
        lbCodecontry.textAlignment = NSTextAlignment .left
        lbCodecontry.text = "(+" + codigoPais + ")"
        lbCodecontry.font = UIFont(name: RobotoFontName.RobotoRegular.rawValue, size: CGFloat(12))
        self.scrollView.addSubview(lbCodecontry)
        self.scrollView.addSubview(imgPhone)

        /*let lb1 = UILabel()
        lb1.frame = CGRect(x: 30, y: txtPhone.frame.maxY + 30, width: viewWidth, height: 40)
        lb1.backgroundColor = UIColor .clear
        lb1.textColor = institutionalColors.claroLightGrayColor
        lb1.textAlignment = NSTextAlignment .left
        lb1.text = conf?.translations?.data?.newRegisterTexts?.newRegisterPrepaidWarning1 ?? ""
        lb1.font = UIFont(name: RobotoFontName.RobotoRegular.rawValue, size: CGFloat(12))
        self.scrollView.addSubview(lb1)
        
        let newRegisterPrepaidWarning2 = conf?.translations?.data?.newRegisterTexts?.newRegisterPrepaidWarning2 ?? ""
        let lb2 = UILabel()
        lb2.frame = CGRect(x: 30, y: lb1.frame.maxY, width: viewWidth - 60, height: 40)
        lb2.backgroundColor = UIColor .clear
        lb2.textColor = institutionalColors.claroLightGrayColor
        lb2.textAlignment = NSTextAlignment .left
        lb2.text = newRegisterPrepaidWarning2
        lb2.font = UIFont(name: RobotoFontName.RobotoRegular.rawValue, size: CGFloat(12))
        lb2.numberOfLines = 2
        lb2.sizeToFit()
        self.scrollView.addSubview(lb2)
        
        let newRegisterPrepaidWarning3 = conf?.translations?.data?.newRegisterTexts?.newRegisterPrepaidWarning3 ?? ""
        let lb3 = UILabel()
        lb3.frame = CGRect(x: 30, y: lb2.frame.maxY + 10, width: viewWidth, height: 40)
        lb3.backgroundColor = UIColor .clear
        lb3.textColor = institutionalColors.claroLightGrayColor
        lb3.textAlignment = NSTextAlignment .left
        lb3.text = newRegisterPrepaidWarning3
        lb3.font = UIFont(name: RobotoFontName.RobotoRegular.rawValue, size: CGFloat(12))
        lb3.sizeToFit()
        self.scrollView.addSubview(lb3)
        
        let newRegisterPrepaidWarning4 = conf?.translations?.data?.newRegisterTexts?.newRegisterPrepaidWarning4 ?? ""
        let lb4 = UILabel()
        lb4.frame = CGRect(x: 30, y: lb3.frame.maxY + 10, width: viewWidth, height: 40)
        lb4.backgroundColor = UIColor .clear
        lb4.textColor = institutionalColors.claroLightGrayColor
        lb4.textAlignment = NSTextAlignment .left
        lb4.text = newRegisterPrepaidWarning4
        lb4.font = UIFont(name: RobotoFontName.RobotoRegular.rawValue, size: CGFloat(12))
        lb4.sizeToFit()
        self.scrollView.addSubview(lb4)*/
        
        
        let validateButton = RedBorderWhiteBackgroundButton(textButton: conf?.translations?.data?.generales?.confirmBtn ?? "Confirmar")
        validateButton.frame = CGRect(x: 30, y: txtPhone.frame.maxY + 40, width: viewWidth - 60, height: textFieldHeight)
        validateButton.addTarget(self, action: #selector(pressConfirmar), for: UIControlEvents.touchUpInside)
        validateButton.alpha = 1.0
        validateButton.isEnabled = true
        self.scrollView.addSubview(validateButton)
        
        self.scrollView.frame = CGRect (x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height - 64)
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height:  validateButton.frame.maxY + 30)
        self.scrollView.backgroundColor = institutionalColors.claroWhiteColor
    }

    

    // MARK: - Action´s
    func pressConfirmar(){
        let lbEmptyField = (conf?.translations?.data?.generales?.emptyField) ?? ""
        //Campos Vacios
        if (txtPhone.text?.isEmpty == true || txtPhone.text?.trimmingCharacters(in: .whitespaces).count == 0){
            txtPhoneMandatory.displayView(customString: lbEmptyField)
        }else{
            txtPhoneMandatory.hideView()
            self.verifyAssociation()
        }
}

    //MARK: -  Servicios - WebServices
    func verifyAssociation(){
        let valueNumberPhone = self.txtPhone.text
        let codigoPais = (mcaManagerSession.getGeneralConfig()?.country?.phoneCountryCode ?? "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "+", with: "")
        let claroNumber = String(format: "%@%@", codigoPais, valueNumberPhone ?? "")
        
        let req = VerifyAssociationToUserIdRequest()
        req.verifyAssociationToUserId?.lineOfBusiness = "3"
        req.verifyAssociationToUserId?.mSISDN = claroNumber
        req.verifyAssociationToUserId?.userProfileID = rut
        
        mcaManagerServer.executeVerifyASsociationToUserId(params: req,
                                                                onSuccess:{ (result) in
                                                                    print(result);
                                                                    //Se quito este servicio
                                                                    //self.getTempPassword()
                                                                 
                                                                    if true == result.0.verifyAssociationToUserIdResponse?.isAssociated{
                                                                        let vcPrepaidRegisterSendMobile = PrepaidRegisterSendMobileVC()
                                                                        vcPrepaidRegisterSendMobile.setMobilePhone(r: valueNumberPhone)
                                                                        vcPrepaidRegisterSendMobile.setRUT(r: self.rut)
                                                                        vcPrepaidRegisterSendMobile.lineOfBussines = TypeLineOfBussines.Postpago
                                                                        vcPrepaidRegisterSendMobile.doLoginWhenFinish = self.doLoginWhenFinish
                                                                        self.navigationController?.pushViewController(vcPrepaidRegisterSendMobile, animated: true)
                                                                    }else{
                                                                        GeneralAlerts.showAcceptOnly(title: NSLocalizedString("accept", comment: ""), text: self.conf?.translations?.data?.newRegisterTexts?.newRegisterFailVerify ?? "El número ingresado no pertenece al titular de la cuenta.", icon: AlertIconType.IconoAlertaError, onAcceptEvent: {})
                            
                                                                    }
                                                              
        },
                                                                onFailure:{
                                                                    (result, myError) in
                                                                    GeneralAlerts.showAcceptOnly(title: NSLocalizedString("accept", comment: ""), text: self.conf?.translations?.data?.newRegisterTexts?.newRegisterFailVerify ?? "El número ingresado no pertenece al titular de la cuenta.", icon: AlertIconType.IconoAlertaError, onAcceptEvent: {})
        })
    }
    
    
    /*func getTempPassword(){
        let req = GetTempPasswordRequest();
        req.getTempPassword?.userProfileId = rut
        req.getTempPassword?.lineOfBusiness = "3"
        WebServicesWithObjects.executeGetTempPassword(params: req,
                                                      onSuccess: {(result : GetTempPasswordResult, resultType : ResultType) in
                                                        //Validar localmente el pin que llego del servicio con lo que el usuario ingresa el los campos, si es igual pasar al formulario vista 05
                                                        
                                                        //Si son iguales paso a la vista PrepaidRegisterStep4VC
                                                    
                                                        
            },
                                                      onFailure: { (result, myError) in
                                                        
                                                        
        })
    }*/
    
    //MARK: -  UITextFieldDelegate
    func textFieldDidChange(_ textField: UITextField) {
        if let currentText = textField.text, let separator = conf?.country?.userProfileIdConfig?.separador, currentText.contains(separator) {
            textField.text = currentText.replacingOccurrences(of: separator, with: "")
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        txtUser.text = rut
        if textField == txtUser {
            textField.keyboardType = .asciiCapable
            if let currentText = textField.text, let separator = conf?.country?.userProfileIdConfig?.separador {
                textField.text = currentText.replacingOccurrences(of: separator, with: "")
            }
        }
   
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var maxText = 10

        
        if textField == txtUser {
            maxText = (conf?.country?.userProfileIdConfig?.max)! - 1
        }
        
        if textField == self.txtPhone{
            let lenght = (mcaManagerSession.getGeneralConfig()?.rules?.mobileNumberRules?.mobileMaxLength) ?? ""
            maxText = (lenght as NSString).integerValue
                if (txtPhone.text?.count)! > 0 {
                    txtPhoneMandatory.hideView()
                }
        }
        
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
        if textField == txtUser {
            let IdentificationNumber = txtUser.text!
            let maskResult = IdentificationNumber.enmascararRut()
            txtUser.text = maskResult.maskedString
        }
     
    }
    
}
