//
//  CodeBySmsVC.swift
//  MiClaro
//
//  Created by Mauricio Javier Perez Flores on 8/2/17.
//  Copyright © 2017 am. All rights reserved.
//

import UIKit
import Cartography
import mcaUtilsiOS
import mcaManageriOS

/// Clase CodeBySmsVC, muestra la pantalla para la validación del código
class CodeBySmsVC: UIViewController {
    
    var doLoginWhenFinish :((_ doAutomaticLogin: Bool) -> Void) = {_ in }

    /// Variable ValidateNumberRequest
    private var reqNum : ValidateNumberRequest?
    /// Variable ValidatePersonalVerificationQuestionRequest
    private var personal : ValidatePersonalVerificationQuestionRequest?
    /// Constante archivo de configuración general
    private let conf = mcaManagerSession.getGeneralConfig()
    /// Botón siguiente
    var nextButton: RedBorderWhiteBackgroundButton!
    /// Contenedor de la vista de código
    var codeContainer: CodeContainerView!
    /// Etiqueta linkeable
    var linkeableLabel: LinkableLabel!
    //For identifier if is Prepago(2) or Postpago(1)
    /// Variable que almacena el TypeLineOfBussines
    var lineOfBusinnes: TypeLineOfBussines?
    /// Variable que almacena el RUT User
    var rutUser: String = ""
    /// Variable que almacena el phoneUser
    var phoneUser: String = ""
    
    var insertCodeLabel: UILabel!
    
    var headerView : UIHeaderForm = UIHeaderForm(frame: .zero)
    var questionLabel : UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: RobotoFontName.RobotoRegular.rawValue, size: 14.0)
        label.textColor = institutionalColors.claroLightGrayColor
        label.textAlignment = .center
        return label
    }()
    
    func setupElements() {
        self.initWith(navigationType:.IconBack, headerTitle: conf?.translations?.data?.registro?.header ?? "")
        self.view.backgroundColor = institutionalColors.claroWhiteColor
        headerView.setupElements(imageName: "ico_seccion_registro", title: conf?.translations?.data?.registro?.header, subTitle: conf?.translations?.data?.registro?.pinValidation)
        self.view.addSubview(headerView)
        
        insertCodeLabel =  UILabel()
        insertCodeLabel.text = "Ingresa tu codigo"
        insertCodeLabel.textAlignment = .center
        self.view.addSubview(insertCodeLabel)
        
        codeContainer = CodeContainerView()
        let width: CGFloat = 0.11 * 5
        codeContainer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width * width, height: 40)
        codeContainer.numberCode =  5
        codeContainer.setPosition()
        self.view.addSubview(codeContainer)
        
        /// TODO : cambiar el texto por el archivo de configuración
        if mcaManagerSession.getLocalConfig()?.enableModulesFeatures?.featuresRegisterModule?[safe: 0]?.enableQuestionLabel ?? false {
            questionLabel.text = conf?.translations?.data?.registro?.pinValidationResendText != nil ? (conf?.translations?.data?.registro?.pinValidationResendText)! : "¿No te ha llegado el código?"
            self.view.addSubview(questionLabel)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(resendCode(sender:)));
        linkeableLabel = LinkableLabel()
        linkeableLabel.addGestureRecognizer(tap)
        linkeableLabel.showText(text: conf?.translations?.data?.generales?.resendPin != nil ? "<b>\(conf!.translations!.data!.generales!.resendPin!)</b>" : "" )
        linkeableLabel.textAlignment = .center
        self.view.addSubview(linkeableLabel)
        
        nextButton = RedBorderWhiteBackgroundButton(textButton: conf?.translations?.data?.generales?.validateBtn != nil ? conf!.translations!.data!.generales!.validateBtn! : "")
        nextButton.addTarget(self, action: #selector(validateCode), for: UIControlEvents.touchUpInside)
        self.view.addSubview(nextButton)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        
        constrain(self.view, headerView, codeContainer, insertCodeLabel) { (view, header, container, codeLabel) in
            header.top == view.top
            header.leading == view.leading
            header.trailing == view.trailing
            header.height == view.height * 0.35
            
            if mcaManagerSession.getLocalConfig()?.enableModulesFeatures?.featuresRegisterModule?[safe: 0]?.enableInsertCodeLabel ?? false {
                
                codeLabel.top == header.bottom
                codeLabel.leading == view.leading
                codeLabel.trailing == view.trailing
                codeLabel.height == view.height * 0.10
                
                
                container.top == codeLabel.bottom + 10.0
                container.centerX == view.centerX
                container.width == view.width * 0.11 * 5
                container.height == 40.0
                
            }else{
                
                container.top == header.bottom + 10.0
                container.centerX == view.centerX
                container.width == view.width * 0.11 * 5
                container.height == 40.0
            }
            
            
            
        }
        
        if mcaManagerSession.getLocalConfig()?.enableModulesFeatures?.featuresRegisterModule?[safe: 0]?.enableQuestionLabel ?? false {
            
            constrain(self.view, codeContainer, questionLabel, linkeableLabel) { (view, container, question, label) in
                question.top == container.bottom + 20.0
                question.leading == view.leading + 31.0
                question.trailing == view.trailing - 32.0
                question.height == 16.0
                
                
                
                label.top == question.bottom + 8.0
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
        }else{
            constrain(self.view, codeContainer, nextButton) { (view, container, button) in
                button.top == container.bottom + 30.0
                button.leading == view.leading + 31.0
                button.trailing == view.trailing - 32.0
                button.height == 40
            }
            
            constrain(self.view, nextButton, linkeableLabel) { (view, container, label) in
                
                label.top == container.bottom + 30.0
                label.leading == view.leading
                label.trailing == view.trailing
                label.height == 18.0
            }
        }
        
        
        
        
    }
    
    
    
    /// Función encargada de cargar las vistas y variables
    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
    }
    override func viewWillAppear(_ animated: Bool) {
        AnalyticsInteractionSingleton.sharedInstance.ADBTrackViewRegistro(viewName: "Registro|Paso 4|Ingresar codigo verificacion",type:4, detenido: false)
    }
    
    /// Setter ValidatePersonalVerificationQuestionRequest
    /// - parameter r: ValidatePersonalVerificationQuestionRequest?
    func setPersonalQuestions(r : ValidatePersonalVerificationQuestionRequest?) {
        self.personal = r;
    }
    /// Setter ValidateNumberRequest
    /// - parameter r: ValidateNumberRequest?
    func setValidateNumber(r : ValidateNumberRequest?) {
        self.reqNum = r;
    }
    /// Función encargada de validar el código
    func validateCode() {
        
        if (5 != codeContainer.getCode().count) {
            print("=========\(codeContainer.getCode())")
        }else{
            print("=========\(codeContainer.getCode())")
            let prepaid5 = CompleteRegisterDBViewController()
            self.navigationController?.pushViewController(prepaid5, animated: true)
        }
        
        
        //        prepaid5.RUT = ""
        //        prepaid5.accountID = ""
        //        prepaid5.email = ""
        //        prepaid5.lineOfBussines = TypeLineOfBussines.Fixed
        //        prepaid5.doLoginWhenFinish = self.doLoginWhenFinish
        
        
        /*AnalyticsInteractionSingleton.sharedInstance.ADBTrackCustomLink(viewName: "Registro|Paso 4|Ingresar codigo verificacion:Validar")
         
         if (4 != codeContainer.getCode().count) {
         GeneralAlerts.showAcceptOnly(text: "Debes ingresar el código de activación completo.", icon: AlertIconType.IconoAlertaError, onAcceptEvent: {})
         return
         }
         
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
         req.validatePersonalVerificationQuestions?.lineOfBusiness = lineOfBusinnes?.rawValue
         mcaManagerServer.executeValidatePersonalVerificationQuestions(params: req,
         onSuccess: { (result) in
         self.callWSAssociateAccount()
         },
         onFailure: { (result, myError) in
         GeneralAlerts.showAcceptOnly(text: result?.validatePersonalVerificationQuestionsResponse?.acknowledgementDescription ?? "", icon: AlertIconType.IconoAlertaError,acceptTitle: NSLocalizedString("accept", comment: ""), onAcceptEvent: {})
         
         })*/
    }
    /// Funcíon que guarda el número
    func guardaNumero() {
        if let r = self.reqNum {
            let req = ValidatePersonalVerificationQuestionRequest();
            let question = SecurityQuestionRequest();
            question.idQuestion = "5";
            question.answer = r.validateNumber?.claroNumber;
            req.validatePersonalVerificationQuestions?.userProfileId = r.validateNumber?.userProfileId
            req.validatePersonalVerificationQuestions?.securityQuestions = [question];
            
            mcaManagerServer.executeValidatePersonalVerificationQuestions(params: req,
                                                                          onSuccess: { (result) in
                                                                            let pswVC = PrepaidRegisterPasswordVC();
                                                                            pswVC.setPersonalQuestions(r: self.personal);
                                                                            pswVC.setValidateNumber(r: r);
                                                                            pswVC.doLoginWhenFinish = self.doLoginWhenFinish
                                                                            self.navigationController?.pushViewController(pswVC, animated: true)
            }, onFailure: { (result, myError) in
                
            })
        }
    }
    /// Función encargada de enviar el código por SMS nuevamente
    /// - parameter sender : Any
    func resendCode(sender: Any) {
        if let r = self.reqNum {
            mcaManagerServer.executeValidateNumber(params: r,
                                                   onSuccess: { (result) in
                                                    GeneralAlerts.showAcceptOnly(title: self.conf?.translations?.data?.generales?.pinAlertTitle ?? "", text: self.conf?.translations?.data?.generales?.pinAlert ?? "", icon: .IconoAlertaSMS, acceptTitle: self.conf?.translations?.data?.generales?.acceptBtn ?? "", acceptBtnColor: institutionalColors.claroBlueColor, onAcceptEvent: {})
            },
                onFailure: { (result, myError) in
                    
            });
        }
    }
    /// Touches began
    /// - parameter touches : Set<UITouch>
    /// - parameter event : UIEvent?
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
    
    /// Función que llama a executeAssociateAccount
    func callWSAssociateAccount() {

        let req = AssociateAccountRequest()
        req.associateAccount = AssociateAccount()
        req.associateAccount?.lineOfBusiness = self.lineOfBusinnes.map { $0.rawValue }
        req.associateAccount?.accountId = self.reqNum?.validateNumber?.claroNumber
        req.associateAccount?.userProfileId = self.reqNum?.validateNumber?.userProfileId//self.rutUser
        req.associateAccount?.associationRoleType = "1"
        req.associateAccount?.accountAssociationStatus = "1"
        req.associateAccount?.notifyMeAboutChanges = true
        
        mcaManagerServer.executeAssociateAccount(params: req, onSuccess: {
            (associateResult, resultType) in
            let pswVC = PrepaidRegisterPasswordVC();
            pswVC.lineOfBussines = self.lineOfBusinnes
            pswVC.setPersonalQuestions(r: self.personal);
            pswVC.setValidateNumber(r: self.reqNum);
            pswVC.doLoginWhenFinish = self.doLoginWhenFinish
            self.navigationController?.pushViewController(pswVC, animated: true)
            
        }, onFailure: {(result, error) in
            let onAcceptEvent = {
                if let container = self.so_containerViewController {
                    container.isSideViewControllerPresented = false;
                }
            }
            
            GeneralAlerts.showAcceptOnly(text: result?.associateAccountResponse?.acknowledgementDescription ?? "", icon: AlertIconType.IconoAlertaError, acceptTitle: NSLocalizedString("accept", comment: ""), onAcceptEvent: onAcceptEvent)
            
        })
    }

}
