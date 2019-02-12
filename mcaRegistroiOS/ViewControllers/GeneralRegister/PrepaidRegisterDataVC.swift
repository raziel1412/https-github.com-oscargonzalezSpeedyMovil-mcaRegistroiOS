//
//  PrepaidRegisterDataVC.swift
//  MiClaro
//
//  Created by Roberto Gutierrez Resendiz on 02/08/17.
//  Copyright © 2017 am. All rights reserved.
//

import UIKit
import Cartography
import MTPopup
import SwiftValidator
import mcaUtilsiOS
import mcaManageriOS

/// Clase encargada de mostrar el primer paso del registro para el App Mi Claro
class PrepaidRegisterDataVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ValidationDelegate {
    
    var doLoginWhenFinish :((_ doAutomaticLogin: Bool) -> Void) = {_ in }
    
    /// Botón para validar
    private var cmdValidar : RedBorderWhiteBackgroundButton?
    /// Botón para mostrar información de RUT
    private var popupRut : MTPopupController?
    /// Botón para mostrar información de Número de serie
    private var popupNumeroSerie : MTPopupController?
    /// TableView
    private var table : UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.separatorStyle = .none
        tableView.bounces = false
        return tableView
    }()
    /// Repsuesta del Servicio Web
    private var respuesta : RetrievePersonalVerificationQuestionsResult?
    /// Constante CeldaTexto
    private let celdaTexto = "CeldaTexto"
    /// Variable que contiene Configuración del país
    private var conf : GeneralConfig?
    /// Arreglo de campos de texto
    private var arrTxt : [SimpleGrayTextFieldQuestionMark] = []
    /// Objeto para validaciones
    private var validador : Validator?
    
    
    private var headerView : UIHeaderForm = UIHeaderForm(frame: .zero)
    
    private typealias completionHandler = () -> Void
    
    private var termsConditions : TermsAndConditions = TermsAndConditions(frame: .zero)
    
    
    /// Function that handles the view
    private func setupViews(completion : completionHandler) {
        validador = Validator()
        conf = mcaManagerSession.getGeneralConfig()
        view.backgroundColor = institutionalColors.claroWhiteColor
        
        self.view.addSubview(headerView)
        headerView.setupElements(imageName: "ico_seccion_registro", title: conf?.translations?.data?.registro?.header, subTitle: conf?.translations?.data?.registro?.registerFirstStep)
        
        table.register(UITableViewCell.self, forCellReuseIdentifier: "CeldaTexto")
        table.delegate = self
        table.dataSource = self
        self.view.addSubview(table)
        let parte1 = conf?.translations?.data?.registro?.registerTyCFirst ?? ""
        let parte2 = conf?.translations?.data?.generales?.termsAndConditions ?? ""
        let parte3 = conf?.translations?.data?.registro?.registerTyCFinal ?? ""
//        let strTerminosYCondiciones = String(format: "%@ <b>%@</b> %@", parte1, parte2, parte3)
        
        termsConditions.setContent(String(format: "%@ <b>%@</b> %@", parte1, parte2, parte3), url: mcaManagerSession.getGeneralConfig()?.termsAndConditions?.url ?? "", title: mcaManagerSession.getGeneralConfig()?.translations?.data?.generales?.termsAndConditions ?? "", acceptTitle: mcaManagerSession.getGeneralConfig()?.translations?.data?.generales?.closeBtn ?? "", offlineAction: {mcaManagerSession.showOfflineMessage()})
        termsConditions.setParentView("Registro")
        self.view.addSubview(termsConditions)
        
        let validateButton = conf?.translations?.data?.generales?.validateBtn ?? ""
        cmdValidar = RedBorderWhiteBackgroundButton(textButton: validateButton)
        self.view.addSubview(cmdValidar!)
        self.cmdValidar?.alpha = 0.5
        self.cmdValidar?.isUserInteractionEnabled = false
        let clickValidar = UITapGestureRecognizer(target: self, action: #selector(cmdValidar_OnClick))
        cmdValidar?.addGestureRecognizer(clickValidar)
        termsConditions.checkBox.addTarget(self, action: #selector(self.chkValidate), for: UIControlEvents.touchUpInside)

        
        setupConstraints()
        completion()
        
    }
    

    func setupConstraints() {
        
        constrain(self.view, headerView) { (view, header) in
            header.top == view.top
            header.leading == view.leading
            header.trailing == view.trailing
            header.height == view.height * 0.35
        }
        
        constrain(self.view, self.table, headerView) { (view, tbl, head) in
            if self.view.frame.size.height > 568.0 {
                tbl.top == head.bottom + 41.0
            } else {
                tbl.top == head.bottom + 21.0
            }
            tbl.leading == view.leading + 32.0
            tbl.trailing == view.trailing - 31.0
            tbl.height >= 50
        }
        let kHeight = self.view.bounds.size.height
        constrain(self.view, termsConditions, table) { (view, terms, tbl) in
            if self.view.frame.size.height > 568.0 {
                terms.top == tbl.bottom + (kHeight * 0.09)
            } else {
                terms.top == tbl.bottom + 18.0
            }
            terms.leading == view.leading + 32.0
            terms.trailing == view.trailing - 31.0
            terms.height == view.height * 0.055
        }
        
        constrain(self.view, termsConditions, cmdValidar!) { (view, terms, button) in
            button.bottom == view.bottom - 14.0
            button.leading == view.leading + 32.0
            button.trailing == view.trailing - 31.0
            button.height == 40.0
            if self.view.frame.size.height > 568.0 {
                terms.bottom == button.top - 42.0
            } else {
                terms.bottom == button.top - 16.0
            }
        }
        
    }
    //MARK: WebServices
    func requestValidation() {
        let req = RetrievePersonalVerificationQuestionRequest();
        req.retrievePersonalVerificationQuestions?.lineOfBusiness = "0";
        req.retrievePersonalVerificationQuestions?.userProfileId = "";
        mcaManagerServer.executeRetrievePersonalVerificationQuestions(params: req,
                                                                            onSuccess: { (result : RetrievePersonalVerificationQuestionsResult, resultType : ResultType) in
                                                                                self.respuesta = result;
                                                                                self.table.reloadData()
        },
                                                                            onFailure: { (result : RetrievePersonalVerificationQuestionsResult?, myError) in
                                                                                self.respuesta = nil;
        });
    }
    
    
    /// Carga inicial, obtención del archivo de configuración, carga del TableView, Carga de información de las etiquetas
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews {
            self.requestValidation()
        }
        
        // Do any additional setup after loading the view.
        
    }
    
    /// Función ejecutada antes de mostrar la vista
    override func viewWillAppear(_ animated: Bool) {
        self.initWith(navigationType:.IconBack, headerTitle: conf?.translations?.data?.registro?.header ?? "")
        AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 1|Ingresar datos",type:1, detenido: false)
    }
    /// Acción del botón de validación, hace uso del Objeto de validación
    func cmdValidar_OnClick() {
            self.validador?.validate(self);
        
        AnalyticsInteractionSingleton.sharedInstance.ADBTrackCustomLink(viewName: "Registro|Paso 1|Ingresar datos:Continuar")
    }
    
    
    @objc func chkValidate(){
        if termsConditions.isChecked == true{
            self.cmdValidar?.isUserInteractionEnabled = true
            self.cmdValidar?.alpha = 1.0
        }else{
            self.cmdValidar?.isUserInteractionEnabled = false
            self.cmdValidar?.alpha = 0.5
        }
    }
    /// Función que evalua si todo esta correcto y realiza la llamada al Servicio Web
    func validationSuccessful() {
        
        for txt in arrTxt {
            if txt.canResignFirstResponder {
                txt.resignFirstResponder();
            }
        }
        var rut : String? = "";
        
        guard let secQuestions = respuesta?.retrievePersonalVerificationQuestionsResponse?.securityQuestions else { return; }
        let req = ValidatePersonalVerificationQuestionRequest();
        var questions = [SecurityQuestionRequest]();
        var i = 0;
        for item in secQuestions {
            let myQuestion = SecurityQuestionRequest();
            let myCell : UITableViewCell? = table.cellForRow(at: IndexPath(row: i, section: 0));
            let texto = myCell?.contentView.subviews[1] as? SimpleGrayTextFieldQuestionMark;
            
            if ("" == texto?.text) {
                GeneralAlerts.showAcceptOnly(text: "empty-fields".localized, icon: AlertIconType.IconoAlertaError, onAcceptEvent: {})
                
                return;
            }
            myQuestion.idQuestion = item.questionId ?? "";
            
            i+=1;
            if "" == myQuestion.idQuestion {
                continue;
            }
            
            if ("RUT" == item.descriptionField) {
                req.validatePersonalVerificationQuestions?.userProfileId = texto?.text! ?? "" //.enmascararRut() ?? "";
                myQuestion.answer = texto?.text! ?? ""
                rut = myQuestion.answer;
                
            } else {
                myQuestion.answer = texto?.text ?? "";
            }
            questions.append(myQuestion);
        }
        
        req.validatePersonalVerificationQuestions?.securityQuestions = questions;
        req.validatePersonalVerificationQuestions?.lineOfBusiness = "0" //"2"
        mcaManagerServer.executeValidatePersonalVerificationQuestions(params: req,
                                                                            onSuccess: { [rut] (result : ValidatePersonalVerificationQuestionsResult, resultType : ResultType) in
                                                                                
                                                                                let code = result.validatePersonalVerificationQuestionsResponse?.acknowledgementCode
                                                                                //Validate for know what view to show
                                                                                if code == "ASSCM-CUSMAN-VALPERVERQUE-SC-3" { //Prepago
                                                                                    let vista = PrepaidRegisterMobileVC();
                                                                                    vista.setPersonalQuestions(r: req);
                                                                                    vista.setRUT(r: rut);
                                                                                    vista.lineOfBussines = TypeLineOfBussines.Prepaid
                                                                                    vista.doLoginWhenFinish = self.doLoginWhenFinish
                                                                                    self.navigationController?.pushViewController(vista, animated: true);
                                                                                }else if code == "ASSCM-CUSMAN-VALPERVERQUE-SC-2" {//Pospago
                                                                                    let pswVC = PrepaidRegisterPasswordVC();
                                                                                    pswVC.setPersonalQuestions(r: req);
                                                                                    pswVC.doLoginWhenFinish = self.doLoginWhenFinish
                                                                                    pswVC.lineOfBussines = TypeLineOfBussines.Postpaid
                                                                                    self.navigationController?.pushViewController(pswVC, animated: true)
                                                                                }
            },
                                                                            onFailure: { (result : ValidatePersonalVerificationQuestionsResult?, myError) in
                                                                     
                                                                                GeneralAlerts.showAcceptOnly(text: result?.validatePersonalVerificationQuestionsResponse?.acknowledgementDescription ?? "", icon: AlertIconType.IconoAlertaError, onAcceptEvent: {})
                                                                                
        });
    }
    /// Función encargada de notificar si existe algún tiempo
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        clearCells()
        errors.forEach({ error in
            print(error)
            if let errorField =  error.1.field as? SimpleGrayTextField {
                getCells().forEach({ cCell in
                    var shouldAddError = false
                    var customError = ""
                    cCell.contentView.subviews.forEach({
                        if let field = $0 as? SimpleGrayTextField {
                            if field == errorField {
                                shouldAddError = true
                            }
                            if field.tag == 1 {
                                let mask = field.text?.enmascararRut()
                                if let error = mask?.errorString, let count = field.text?.count, count > 0 {
                                    customError = error
                                    shouldAddError = true
                                }
                            } else if field.tag == 3 {
                                if let count = field.text?.count, count > 0, let valid = field.text?.isValidEmail(), !valid {
                                    shouldAddError = true
                                    if let _  = mcaManagerSession.getGeneralConfig()?.country?.userProfileIdConfig?.msgError {
                                        customError = (mcaManagerSession.getGeneralConfig()?.country?.userProfileIdConfig?.msgError)!
                                    }
                                }
                            }
                        }
                        if let errorBox = $0 as? MandatoryInformation {
                            if shouldAddError {
                                shouldAddError = false
                                errorBox.displayView(customString: customError.count > 0 ? customError : error.0.validationText)
                                AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 1|Ingresar datos|Detenido",type:1, detenido: true, mensaje:"Campo obligatorio")
                                customError = ""
                            }
                        }
                    })
                })
            }
        })
        
        
        
        
        
        /*
        if let item = errors.first {
            let alert = AlertAcceptOnly();
            alert.text = item.1.errorMessage;// "Ingresa todos los campos";
            NotificationCenter.default.post(name: Observers.ObserverList.AcceptOnlyAlert.name, object: alert);
        }*/
    }
    /// Cerrar el popup informativo de RUT
    func closeRutPopup() {
        if let popup = popupRut {
            popup.dismiss();
        }
        
        popupRut = nil;
    }
    /// Cierre del popup informativo de número de serie
    func closeNumeroSeriePopup() {
        if let popup = popupNumeroSerie {
            popup.dismiss();
        }
        
        popupNumeroSerie = nil;
    }
    /// Número de secciones para el TableView
    /// - parameter tableView: UITableView
    /// - Returns: Int
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    /// Altura para cada Row
    /// - parameter tableView: UITableView
    /// - parameter indexPath: IndexPath
    /// - Returns: CGFLoat
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60;
    }
    /// Número de Rows por secciones
    /// - parameter tableView: UITableView
    /// - parameter section: Int
    /// - Returns: Int
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return respuesta?.retrievePersonalVerificationQuestionsResponse?.securityQuestions?.count ?? 0;
    }
    /// Celda para un Row específico
    /// - parameter tableView: UITableView
    /// - parameter indexPath: IndexPath
    /// - Returns: UITableViewCell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: celdaTexto, for: indexPath);
        
        if 0 == indexPath.row {
            arrTxt = [];
        }
        
        if let item = respuesta?.retrievePersonalVerificationQuestionsResponse?.securityQuestions?[safe: indexPath.row] {
            let rutText = item.descriptionField ?? ""
            let txtRut = SimpleGrayTextFieldQuestionMark(text: rutText, placeholder: rutText);
            let iconImage = UIImageView(frame: .zero)
            let mandatory = MandatoryInformation(frame: .zero)
            //txtRut.frame = CGRect(x: 0, y: 0, width: cell.contentView.frame.size.width - 32, height: 21)
            //txtRut.delegate = nil;
            txtRut.delegate = self;
            arrTxt.append(txtRut);
            print(rutText)
            switch rutText {
            case "Ingresa tu RUT", "RUT":
                //txtRut.showQuestionMark();
                txtRut.hideQuestionMark()
                txtRut.keyboardType = .asciiCapable
                //txtRut.action = creaDialog(titulo: rutText);
                txtRut.tag = Int(item.questionId ?? "1")!;
                
                txtRut.autocorrectionType = .no
                txtRut.addTarget(self, action: #selector(textFieldDidBeginEditing(_:)), for: .editingDidBegin)
                txtRut.autocapitalizationType = UITextAutocapitalizationType.allCharacters
                iconImage.image = mcaUtilsHelper.getImage(image: "icon_rut_input")
                //validador?.registerField(txtRut, rules: [RequiredRule(message: String(format: "Se requiere escribir el %@", rutText))]);
                validador?.registerField(txtRut, rules: [RequiredRule(message: "empty-fields".localized)])
            case "Número de serie", "Numero de serie", "Número de Serie", "Numero de Serie", "NÃºmero de serie":
                txtRut.showQuestionMark();
                txtRut.keyboardType = .asciiCapable;
                txtRut.action = creaDialog(titulo: (rutText == "Numero de serie" ? "numero-de-serie".localized : rutText));
                txtRut.tag = Int(item.questionId ?? "2")!;
                txtRut.autocorrectionType = .no
                txtRut.autocapitalizationType = .none
                iconImage.image = mcaUtilsHelper.getImage(image: "icon_numserie_input")
                //validador?.registerField(txtRut, rules: [RequiredRule(message: String(format: "Se requiere escribir el %@", rutText))]);
                validador?.registerField(txtRut, rules: [RequiredRule(message: "empty-fields".localized)])
            case "Correo eléctronico", "Correo", "Correo electronico":
                txtRut.hideQuestionMark();
                txtRut.keyboardType = .emailAddress;
                
                //txtRut.action = creaRutDialog();
                txtRut.tag = Int(item.questionId ?? "3")!;
                txtRut.autocapitalizationType = .none
                txtRut.autocorrectionType = .no
                iconImage.image = mcaUtilsHelper.getImage(image: "icon_correo_input")
                //validador?.registerField(txtRut, rules: [RequiredRule(message: String(format: "Se requiere escribir el %@", rutText)),
                //EmailRule(message: "El formato del correo electrónico es incorrecto")])
                validador?.registerField(txtRut, rules: [RequiredRule(message: "empty-fields".localized), EmailRule(message: "El formato del correo electrónico es incorrecto")])
            default:
                txtRut.hideQuestionMark();
                txtRut.keyboardType = .asciiCapable;
                txtRut.tag = 0;
                txtRut.autocapitalizationType = .none
            }
            
            //txtRut.autocapitalizationType = .none;
            cell.selectionStyle = .none
            cell.contentView.addSubview(iconImage)
            cell.contentView.addSubview(txtRut)
            cell.contentView.addSubview(mandatory)
            
            constrain(cell.contentView, txtRut, iconImage, mandatory) { (parent, txt, image, mandatory) in
                image.leading == parent.leading
                image.bottom  == parent.bottom - 20
                image.width == 22.0
                image.height == 22.0
                txt.top == parent.top
                txt.leading == parent.leading + 32;
                txt.trailing == parent.trailing ;
                txt.bottom == mandatory.top
                mandatory.height == 20
                mandatory.leading == parent.leading + 32
                mandatory.trailing == parent.trailing
                mandatory.bottom == parent.bottom
            }
        }
        return cell;
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
           
            
            /*
            let info = BottomInfoVC(titulo: titulo);
            
            self.popupRut = MTPopupController(rootViewController: info);
            self.popupRut?.hidesCloseButton = true;
            self.popupRut?.navigationBarHidden = true;
            self.popupRut?.style = .bottomSheet;
            let closeRutPopup = UITapGestureRecognizer(target: self, action: #selector(self.closeRutPopup));
            self.popupRut?.backgroundView?.addGestureRecognizer(closeRutPopup);
            self.popupRut?.present(in: self);*/
        };
        
    }
    /// Alerta de insuficiencia de memoria
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UITextFieldDelegate
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
        if 1 == textField.tag {//RUT
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string) as String
            let nsString = NSString(string: newString)
            return !(nsString.length > lenght)
        }
        
        return true
    }
    /// Función que determina cuando un campo de texto ha finalizado su edición, muestra una alerta de aplicar
    /// - parameter textField: Campo en cuestión
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let cells = getCells()
        cells.forEach({ cCell in
            cCell.contentView.subviews.forEach({
                if let tField = $0 as? SimpleGrayTextField, tField == textField, let count = textField.text?.count, count > 0 {
                    clearCell(cell: cCell)
                }
            })
        })
        
        if textField.tag == 3 {
            if let count = textField.text?.count, count > 0, let valid = textField.text?.isValidEmail(), !valid {
                if let _  = mcaManagerSession.getGeneralConfig()?.country?.userProfileIdConfig?.msgError {
                    let customError = (mcaManagerSession.getGeneralConfig()?.country?.userProfileIdConfig?.msgError)!
                    cells.forEach({ cCell in
                        cCell.contentView.subviews.forEach({
                            if let tField = $0 as? SimpleGrayTextField, tField == textField {
                                displayErrorCell(cell: cCell, error: customError)
                            }
                        })
                    })
                }
                
            }
        }
        
        if 1 == textField.tag {
            let IdentificationNumber = textField.text!
            let maskedString = IdentificationNumber.enmascararRut()
            textField.text = maskedString.maskedString
            if let errorString = maskedString.errorString {
                /*let alert = AlertAcceptOnly();
                alert.title = "error-title-response".localized;
                alert.text = errorString;
                NotificationCenter.default.post(name: Observers.ObserverList.AcceptOnlyAlert.name, object: alert);*/
                cells.forEach({ cCell in
                    cCell.contentView.subviews.forEach({
                        if let tField = $0 as? SimpleGrayTextField, tField == textField {
                            displayErrorCell(cell: cCell, error: errorString)
                        }
                    })
                })
            }
        }
    }
    
    func displayErrorCell(cell: UITableViewCell, error: String) {
        cell.contentView.subviews.forEach({
            if let errorBox = $0 as? MandatoryInformation {
                errorBox.displayView(customString: error)
                AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 1|Ingresar datos|Detenido",type:1, detenido: true, mensaje:error)
            }
        })
    }
    
    
    func getCells() -> [UITableViewCell] {
        var cells = [UITableViewCell]()
        let index = self.table.numberOfRows(inSection: 0)
        for i in 0...index {
            if let cell = self.table.cellForRow(at: IndexPath.init(row: i, section: 0)) {
                cells.append(cell)
            }
        }
        return cells
    }
    
    func clearCell(cell : UITableViewCell) {
        getCells().forEach({ cCell in
            if cCell == cell {
                cCell.contentView.subviews.forEach({
                    if let errorBox = $0 as? MandatoryInformation {
                        errorBox.hideView()
                    }
                })
            }
        })
    }
    
    func clearCells() {
        getCells().forEach({ cCell in
            cCell.contentView.subviews.forEach({
                if let errorBox = $0 as? MandatoryInformation {
                    errorBox.hideView()
                }
            })
        })
    }
    
    
}

