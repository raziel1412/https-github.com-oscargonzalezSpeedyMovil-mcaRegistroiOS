//
//  PrepaidRegisterMobileVC.swift
//  MiClaro
//
//  Created by Mauricio Javier Perez Flores on 8/1/17.
//  Copyright © 2017 am. All rights reserved.
//

import UIKit
import Cartography
import mcaUtilsiOS
import mcaManageriOS

/// Clase encargada de mostrar la vista para agrega el número de teléfono
class PrepaidRegisterMobileVC: UIViewController, UITextFieldDelegate {
    
    var doLoginWhenFinish :((_ doAutomaticLogin: Bool) -> Void) = {_ in }
    
    /// Constante con los datos del archivo de configuración.
    let conf = mcaManagerSession.getGeneralConfig()
    /// Clase que almacena el request para preguntas de seguridad
    private var personal : ValidatePersonalVerificationQuestionRequest?
    /// Cadena que almacena el RUT
    private var rut : String?
    /// Botón de siguiente
    var nextButton: RedBorderWhiteBackgroundButton!
    /// Etiqueta de instrucciónes
    ///var instructionLabel: InstructionLabel!
    /// Vista que contiene el campo de texto para el número de teléfono
    var mobilePhoneView: MobilePhoneNumberContainerView!
    /// Line of business
    var lineOfBussines: TypeLineOfBussines?
    
    var headerView : UIHeaderForm = UIHeaderForm(frame: .zero)
    
    
    func setupElements() {
        self.initWith(navigationType:.IconBack, headerTitle: conf?.translations?.data?.registro?.header ?? "")
        self.view.backgroundColor = institutionalColors.claroWhiteColor;
        headerView.setupElements(imageName: "ico_seccion_registro", title: conf?.translations?.data?.registro?.header, subTitle: conf?.translations?.data?.registro?.registerPrepaid)
        self.view.addSubview(headerView)
        mobilePhoneView = MobilePhoneNumberContainerView()
        mobilePhoneView.mobileTextfield.delegate = self
        self.view.addSubview(mobilePhoneView)
        let next = conf?.translations?.data?.generales?.nextBtn
        nextButton = RedBorderWhiteBackgroundButton(textButton: next != nil ? next! : "")
        nextButton.addTarget(self, action: #selector(btnContinueAction), for: UIControlEvents.touchUpInside)
        self.view.addSubview(nextButton)
        setupConstraints()
    }
    
    func setupConstraints() {
        constrain(self.view, headerView, mobilePhoneView, nextButton) { (view, header, phone, next) in
            header.top == view.top
            header.leading == view.leading
            header.trailing == view.trailing
            header.height == view.height * 0.35
            phone.top == header.bottom + 40.0
            phone.leading == view.leading + 31.0
            phone.trailing == view.trailing - 32.0
            phone.height == 66.0
            next.top == phone.bottom + 50.0
            next.leading == view.leading + 31.0
            next.trailing == view.trailing - 32.0
            next.height == 40
        }
    }
    
    /// Carga inicial, una vez que la vista se muestra, inicializa el ScrollView, agrega las vistas y etiquetas necesarias como SubViews del ScrollView
    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 2|Ingresar numero movil",type:2, detenido: false)
    }
    
    //MARK: TextfieldDelegate
    /// Función que permite determinar si el texto ingresado son caracteres validos y modifica / agrega / Elimina o no el caracter
    /// - parameter textField: campo de texto que se está editando
    /// - parameter range: Rango de los caracteres
    /// - parameter string: Cadena a anexar
    /// - Returns: Bool
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        /*let maxLength = 9
        if string.count == 0 {
            return true
        }
        if let text = textField.text, text.count > maxLength - 1 {
            return false
        }
        return true*/
        
        let lenght = (mcaManagerSession.getGeneralConfig()?.rules?.mobileNumberRules?.mobileMaxLength) ?? ""
        let lenghtStr = (lenght as NSString).integerValue
        if (mobilePhoneView.mobileTextfield.text != nil) {
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string) as String
            let nsString = NSString(string: newString)
            return !(nsString.length > lenghtStr)
        
        }
           return true
    }
    /// Función que permite asignar la cadena del RUT a la variable
    func setRUT(r : String?) {
        self.rut = r;
    }
    /// Función que permite asignar las preguntas de verificación
    func setPersonalQuestions(r : ValidatePersonalVerificationQuestionRequest?) {
        self.personal = r;
    }
    /// Función que valida que los datos proporcionados cumplan con los critierios necesarios antes de llamar al servicio web, encargado de enviar un SMS para culminar el registro
    func btnContinueAction() {
        AnalyticsInteractionSingleton.sharedInstance.ADBTrackCustomLink(viewName: "Registro|Paso 2|Ingresar numero movil: Continuar")//NO
        
        if mobilePhoneView.mobileTextfield.canResignFirstResponder {
            mobilePhoneView.mobileTextfield.resignFirstResponder();
        }
        
        if "" != mobilePhoneView.mobileTextfield.text, let text = mobilePhoneView.mobileTextfield.text, text.trimmingCharacters(in: .whitespaces).count >= 8{ //9 {
          
            let codigoPais = (mcaManagerSession.getGeneralConfig()?.country?.phoneCountryCode ?? "").digitsOnly
            let claroNumber = String(format: "%@%@", codigoPais, mobilePhoneView.mobileTextfield.text!);
            
            let vista = PrepaidRegisterSendMobileVC(nibName: "PrepaidRegisterSendMobileVC", bundle: nil)
            vista.setRUT(r: self.rut);
            vista.setPersonalQuestions(r: self.personal)
//            vista.setReqNum(r: req)
            vista.lineOfBussines = TypeLineOfBussines.Prepaid
            vista.doLoginWhenFinish = self.doLoginWhenFinish
            vista.setMobilePhone(r: claroNumber)
            vista.view.frame = self.view.frame
            
            self.navigationController?.pushViewController(vista, animated: true);
            
        } else if let count = mobilePhoneView.mobileTextfield.text?.count, count < 8, count > 0{
            mobilePhoneView.setMandatory(title: "nine-digits".localized)
            /*
             let accept = AlertAcceptOnly()
             accept.text = "nine-digits".localized
             accept.acceptTitle = NSLocalizedString("accept", comment: "");
             NotificationCenter.default.post(name: Observers.ObserverList.AcceptOnlyAlert.name,
             object: accept);*/
        } else {
            mobilePhoneView.setMandatory(title: "")
            /*let alert = AlertAcceptOnly();
             let message = "empty-fields".localized
             alert.text = message
             NotificationCenter.default.post(name: Observers.ObserverList.AcceptOnlyAlert.name, object: alert);*/
        }
    }
    /// Función que permite determinar si el screen ha sido tocado en algún punto, de esta manera podrá realizar la accion de endEditing en el campo asignado
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    /// Alerta de insuficiencia de memoria
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
