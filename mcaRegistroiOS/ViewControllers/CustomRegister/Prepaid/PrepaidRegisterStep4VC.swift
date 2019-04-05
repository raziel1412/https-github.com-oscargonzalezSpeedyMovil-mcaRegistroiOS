//
//  PrepaidRegisterStep4VC.swift
//  MiClaro
//
//  Created by Pilar del Rosario Prospero Zeferino on 8/21/18.
//  Copyright © 2018 am. All rights reserved.
//

import UIKit
import Cartography
import mcaUtilsiOS
import mcaManageriOS

/// Clase encargada de llevar a cabo la segúnda fase de validación para agregar un prepago
class PrepaidRegisterStep4VC: UIViewController {
    
    var doLoginWhenFinish :((_ doAutomaticLogin: Bool) -> Void) = {_ in }
    
    /// Botón de siguiente
    var nextButton: RedBorderWhiteBackgroundButton!
    /// Vista de contenedor del código donde se ingresará el enviado por SMS
    var codeContainer: CodeContainerView!
    var questionCodeLabel: UILabel!
    /// Etiqueta con acción para reenviar el código
    var linkeableLabel: LinkableLabel!
    /// Constante que almacena la configuración
    let conf = mcaManagerSession.getGeneralConfig()
    
    var previousView = TypeRegisterView.Register
    
    /// Variable ValidateNumberRequest
    private var reqNum : ValidateNumberRequest?
    /// Variable ValidatePersonalVerificationQuestionRequest
    private var personal : ValidatePersonalVerificationQuestionRequest?
    /// Variable que almacena el TypeLineOfBussines
    var LoB: TypeLineOfBussines = TypeLineOfBussines.Fixed
    /// Variable que almacena el RUT User
    var RUT: String = ""
    /// Variable que almacena el phoneUser
    var phoneUser: String = ""
    
    var headerView : UIHeaderForm = UIHeaderForm(frame: .zero)
    
    func setValues(number: String, rut: String, Lob: TypeLineOfBussines, req: ValidateNumberRequest? = nil, personalQ: ValidatePersonalVerificationQuestionRequest? = nil) {
        phoneUser = number
        RUT = rut
        LoB = Lob
        reqNum = req
        personal = personalQ
    }
    
    func setupElements() {
        self.view.backgroundColor = institutionalColors.claroWhiteColor
        self.initWith(navigationType:.IconBack, headerTitle: conf?.translations?.data?.registro?.header ?? "")
        let scrollView : UIScrollView = UIScrollView(frame: .zero)
        let viewContainer : UIView = UIView(frame: self.view.bounds)
        headerView.setupElements(imageName: "ico_seccion_registro", title: conf?.translations?.data?.newRegisterTexts?.newRegisterTitle, subTitle: conf?.translations?.data?.newRegisterTexts?.newRegisterpinValidation)
        viewContainer.addSubview(headerView)
        codeContainer = CodeContainerView()
        codeContainer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width * 0.45, height: 40)
        codeContainer.numberCode =  4
        codeContainer.setPosition()
        codeContainer.setKeyboardType(tipoTeclado: .numberPad)
        viewContainer.addSubview(codeContainer)
        let tap = UITapGestureRecognizer(target: self, action: #selector(resendCode(sender:)));
        questionCodeLabel = UILabel()
        questionCodeLabel.text = conf?.translations?.data?.newRegisterTexts?.newRegisterpinValidationResendText ?? ""
        questionCodeLabel.font = UIFont(name: RobotoFontName.RobotoRegular.rawValue, size: CGFloat(14))
        questionCodeLabel.textColor = institutionalColors.claroLightGrayColor
        questionCodeLabel.textAlignment = .center
        self.view.addSubview(questionCodeLabel)
        linkeableLabel = LinkableLabel()
        linkeableLabel.addGestureRecognizer(tap)
        linkeableLabel.showTextWithoutUnderline(text: conf?.translations?.data?.generales?.resendPin != nil ? "<b>\(conf!.translations!.data!.generales!.resendPin!)</b>" : "" )
        linkeableLabel.textAlignment = .center
        viewContainer.addSubview(linkeableLabel)
        nextButton = RedBorderWhiteBackgroundButton(textButton: conf?.translations?.data?.generales?.validateBtn ?? "")
        nextButton.addTarget(self, action: #selector(validateCode), for: UIControlEvents.touchUpInside)
        viewContainer.addSubview(nextButton)
        scrollView.addSubview(viewContainer)
        scrollView.frame = viewContainer.bounds
        scrollView.contentSize = viewContainer.bounds.size
        self.view.addSubview(scrollView)
        setupConstraints(view: viewContainer)
    }
    
    func setupConstraints(view: UIView) {
        constrain(self.view, headerView, codeContainer) { (view, header, container) in
            header.top == view.top
            header.leading == view.leading
            header.trailing == view.trailing
            header.height == view.height * 0.35
            
            container.top == header.bottom + 10.0
            container.centerX == view.centerX
            container.width == view.width * 0.45
            container.height == 40.0
        }
        
        constrain(self.view, codeContainer, questionCodeLabel, linkeableLabel) { (view, container, questionLabel, label) in
            
            questionLabel.top == container.bottom + 16.0
            questionLabel.leading == view.leading + 31.0
            questionLabel.trailing == view.trailing - 31.0
            questionLabel.height == 18.0
            
            label.top == questionLabel.bottom + 16.0
            label.leading == view.leading + 31.0
            label.trailing == view.trailing - 31.0
            label.height == 18.0
        }
        
        constrain(self.view, linkeableLabel, nextButton) { (view, label, button) in
            button.top == label.bottom + 38.0
            button.leading == view.leading + 31.0
            button.trailing == view.trailing - 32.0
            button.height == 40
        }
        
    }
    
    
    /// Función encargada de inicializar elementos de la vista e inicializar variables
    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
    }
    
    /// Función encargada de validar el código introducido con el del SMS
    func validateCode() {
        if (4 != codeContainer.getCode().count) {
            GeneralAlerts.showAcceptOnly(text: "Debes ingresar el código de activación completo.", icon: .IconoAlertaError, onAcceptEvent: {})
            return;
        }
        
        let timeSMS = AnalyticsInteractionSingleton.sharedInstance.stopTimer()
        if previousView == TypeRegisterView.AddPrepaid{
            AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewServicioPrepago(viewName: "Mis servicios|Agregar prepago|Paso 4|Ingresar codigo verificacion", type: "4", detenido: false, intervalo: timeSMS)
            AnalyticsInteractionSingleton.sharedInstance.ADBTrackCustomLink(viewName: "Mis servicios|Agregar prepago|Paso 4|Ingresar codigo verificacion:Valida")
        }else{
            let typeLoB = LoB == TypeLineOfBussines.Prepaid ? "1" : LoB == TypeLineOfBussines.Postpaid ? "2" : ""
            AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 5|Ingresar codigo verificacion", type:5, detenido: false, typeLoB: typeLoB, intervalo: timeSMS)
            AnalyticsInteractionSingleton.sharedInstance.ADBTrackCustomLink(viewName: "Registro|Paso 5|Ingresar codigo verificacion:Validar")
        }
        let shouldContinue = self.shouldContinue()
        if shouldContinue.should {
            switch LoB {
            case .Fixed:
                break
            case .Prepaid:
                self.callWSvalidateCodePrepaid()
                break
            case .Postpaid:
                self.callWSvalidateCodePrepaid()
                break
            }
            
        } else {
            GeneralAlerts.showAcceptOnly(text: shouldContinue.errorString ?? NSLocalizedString("debes-ingresar-codigo-verificacion", comment: ""), icon: .IconoAlertaError, onAcceptEvent: {})
            return
        }
    }
    /// Función que determina si se debe continuar
    /// - Returns should: Bool
    /// - Returns errorString : String?
    func shouldContinue() -> ( should: Bool, errorString : String?) {
        if (codeContainer.getCode().count != 4) {
            return (false, NSLocalizedString("debes-ingresar-codigo-verificacion", comment: ""))
        } else {
            return (true, nil)
        }
    }
    /// Función encargada de llamar al Servicio Web para re-enviar el código
    func resendCode(sender: Any) {
        switch LoB {
        case .Fixed:
            break
        case .Prepaid:
            self.resendCodePrepaid()
            break
        case .Postpaid:
            self.resendCodePrepaid()
            break
        }
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
    
    func resendCodePrepaid() {
        
        AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 2|Enviar codigo verificacion", type:2, detenido: false)
        AnalyticsInteractionSingleton.sharedInstance.ADBTrackCustomLink(viewName: "Registro|Paso 2|Enviar codigo verificacion:Enviar")
        
        let req = ValidateNumberRequest();
        req.validateNumber?.claroNumber = self.phoneUser;
        req.validateNumber?.userProfileId = self.RUT;
        req.validateNumber?.lineOfBusiness = LoB.rawValue
        
        mcaManagerServer.executeValidateNumber(params: req, onSuccess: { (result) in
            let onAcceptEvent = {
                if let container = self.so_containerViewController {
                    container.isSideViewControllerPresented = false;
                }
                
                self.reqNum = req
                AnalyticsInteractionSingleton.sharedInstance.ADBTrackCustomLink(viewName: "Registro|Paso 3|Mensaje enviado:Cerrar")
            }
            
            GeneralAlerts.showAcceptOnly(title: self.conf?.translations?.data?.generales?.pinAlertTitle ?? "", text: self.conf?.translations?.data?.generales?.pinAlert ?? "", icon: .IconoAlertaSMS, acceptTitle: self.conf?.translations?.data?.generales?.acceptBtn ?? "", acceptBtnColor: institutionalColors.claroBlueColor, onAcceptEvent: onAcceptEvent)
            
            AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 3|Mensaje enviado",type:3, detenido: false)
                                                        
        }, onFailure: { (result, myError) in
            GeneralAlerts.showAcceptOnly(text: result?.validateNumberResponse?.acknowledgementDescription ?? "", icon: .IconoAlertaError, onAcceptEvent: {})
        });
        
    }
    
    
    /// Web Services para validación del codigo
    func callWSvalidateCodePrepaid() {
        
        let req = ValidatePersonalVerificationQuestionRequest();
        var questions = [SecurityQuestionRequest]()
        
        let question = SecurityQuestionRequest();
        question.idQuestion = "4";
        question.answer = codeContainer.getCode();
        questions.append(question)
        
        /****************/
        let questionRut = SecurityQuestionRequest();
        questionRut.idQuestion = "1";
        questionRut.answer = self.reqNum?.validateNumber?.userProfileId//self.rutUser
        questions.append(questionRut)
        
        let questionPhone = SecurityQuestionRequest();
        questionPhone.idQuestion = "6";
        questionPhone.answer = self.reqNum?.validateNumber?.claroNumber//self.phoneUser
        questions.append(questionPhone)
        /****************/
        req.validatePersonalVerificationQuestions?.securityQuestions = questions//[question];
        req.validatePersonalVerificationQuestions?.userProfileId = reqNum?.validateNumber?.userProfileId
        req.validatePersonalVerificationQuestions?.lineOfBusiness = LoB.rawValue
        
        //******Codigo HardCode para brincar la validacion del pin
        //        let prepaid5 = PrepaidRegisterStep5VC()
        //        prepaid5.RUT = self.RUT
        //        prepaid5.numberPhone = self.phoneUser
        //        prepaid5.setValidateNumber(r: self.reqNum)
        //        prepaid5.lineOfBussines = self.LoB
        //        self.navigationController?.pushViewController(prepaid5, animated: true)
        //
        //        return
        
        mcaManagerServer.executeValidatePersonalVerificationQuestions(params: req, onSuccess: { (result, resultType) in
            let prepaid5 = PrepaidRegisterStep5VC()
            prepaid5.RUT = self.RUT
            prepaid5.numberPhone = self.phoneUser
            prepaid5.setValidateNumber(r: self.reqNum)
            prepaid5.lineOfBussines = self.LoB
            prepaid5.doLoginWhenFinish = self.doLoginWhenFinish
            self.navigationController?.pushViewController(prepaid5, animated: true)
        }, onFailure: { (result, myError) in
            let onAcceptEvent = {
                if let container = self.so_containerViewController {
                    container.isSideViewControllerPresented = false;
                }
            }
            GeneralAlerts.showAcceptOnly(title:NSLocalizedString("accept", comment: ""), text:result?.validatePersonalVerificationQuestionsResponse?.acknowledgementDescription ?? "",icon: AlertIconType.IconoAlertaError, onAcceptEvent: onAcceptEvent)
            
        })
    }
}
