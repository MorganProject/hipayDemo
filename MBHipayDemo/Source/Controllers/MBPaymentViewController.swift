//
//  MBPaymentViewController.swift
//  MBHipayDemo
//
//  Created by Morgan on 28/08/2018.
//  Copyright © 2018 MB. All rights reserved.
//

import UIKit
import HiPayFullservice

class MBPaymentViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var placeholderTexField: UITextField!
    @IBOutlet weak var cardNumberTextField: HPFCardNumberTextField!
    @IBOutlet weak var expirationDateTextField: HPFExpiryDateTextField!
    @IBOutlet weak var securityCodeTextField: HPFSecurityCodeTextField!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placeholderTexField.delegate = self
        placeholderTexField.autocorrectionType = .no;
        
        cardNumberTextField.delegate = self
        expirationDateTextField.delegate = self
        securityCodeTextField.delegate = self
    }
    
    func validForm() -> Bool {
        if let placeholderLength = placeholderTexField.text?.count {
            return placeholderLength > 0 && cardNumberTextField.isValid && expirationDateTextField.isValid && securityCodeTextField.isValid
        }
        return false
    }
    
    @IBAction func payButtonTouched(_ sender: Any) {
        if (validForm()) {
            let placeholder = placeholderTexField.text!
            let year = String.init(format: "%ld", expirationDateTextField.dateComponents.year!)
            let month = String.init(format: "%02ld", expirationDateTextField.dateComponents.month!)
            let cardNumber = cardNumberTextField.text!
            let securityCode = securityCodeTextField.text!
            
            activityIndicatorView.startAnimating()
            HPFSecureVaultClient.shared().generateToken(withCardNumber: cardNumber,
                                                        cardExpiryMonth: month,
                                                        cardExpiryYear: year,
                                                        cardHolder: placeholder,
                                                        securityCode: securityCode,
                                                        multiUse: false) { (token, error) in
                                                            DispatchQueue.main.async {
                                                                self.activityIndicatorView.stopAnimating()
                                                                
                                                                var message = ""
                                                                var title = ""
                                                                if let errorUnwrap : NSError = error as NSError?, let parseRespondeBody = errorUnwrap.userInfo[HPFErrorCodeHTTPParsedResponseKey] {
                                                                    title = "Echec"
                                                                    message = "La transaction a échoué ! \n\(parseRespondeBody)"
                                                                }
                                                                else {
                                                                    title = "Succès"
                                                                    message = "La transaction a réussi avec succès"
                                                                }
                                                                
                                                                let alertVC = UIAlertController.init(title: title, message:message , preferredStyle: .alert)
                                                                alertVC.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                                                                self.present(alertVC, animated: true, completion: nil)
                                                            }
            }
        }
        else {
            let alertVC = UIAlertController.init(title: "Echec", message:"Les informations ne sont pas valides" , preferredStyle: .alert)
            alertVC.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == placeholderTexField) {
            cardNumberTextField.becomeFirstResponder()
        }
        else if (textField == cardNumberTextField) {
            expirationDateTextField.becomeFirstResponder()
        }
        else if (textField == expirationDateTextField) {
            securityCodeTextField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        
        return true
    }
}
