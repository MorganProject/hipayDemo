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
    
    func createRequest() -> HPFOrderRequest {
        let request = HPFOrderRequest.init()
        request.amount = NSNumber(value: 100.00)
        request.currency = "EUR"
        request.orderId = "TEST_\(Int(arc4random()))"
        request.shortDescription = "My shopping list"
        request.operation = .sale
        request.paymentProductCode = HPFPaymentProductCodeVisa
        return request
    }
    
    func generateRequestSignature(orderID : String, amount : NSNumber, currency : String, passPhrase : String) -> String {
        let signature = "\(orderID)\(String.init(format: "%.2f", amount.doubleValue))\(currency)\(passPhrase)"
        return signature.sha1()
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
                                                        multiUse: false) { (cardToken, error) in
                                                            if let token = cardToken?.token {
                                                                let request = self.createRequest()
                                                                request.paymentMethod = HPFCardTokenPaymentMethodRequest.init(token: token, eci: .HPFECISecureECommerce, authenticationIndicator: .bypass)
                                                                
                                                                if let orderID = request.orderId, let amount = request.amount, let currency = request.currency {
                                                                    let signature = self.generateRequestSignature(orderID: orderID,
                                                                                                                  amount: amount,
                                                                                                                  currency: currency,
                                                                                                                  passPhrase: "32JUWB3veDWWmHySNJvtvPyBnqrDFEHbaP3jr")
                                                                    
                                                                    HPFGatewayClient.shared().requestNewOrder(request, signature: signature, withCompletionHandler: { (transaction, error) in
                                                                        self.activityIndicatorView.stopAnimating()
                                                                        
                                                                        if let error = error {
                                                                            let alertVC = UIAlertController.init(title: "Echec", message:"La transaction a échoué ! (\(error)" , preferredStyle: .alert)
                                                                            alertVC.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                                                                            self.present(alertVC, animated: true, completion: nil)
                                                                        }
                                                                        else {
                                                                            let alertVC = UIAlertController.init(title: "Succès", message:"La transaction a réussi avec succès" , preferredStyle: .alert)
                                                                            alertVC.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                                                                            self.present(alertVC, animated: true, completion: nil)
                                                                        }
                                                                    })
                                                                    
                                                                }
                                                                
                                                            }
                                                            else if let error : NSError = error as NSError?, let parsedResponseKey = error.userInfo[HPFErrorCodeHTTPParsedResponseKey] {
                                                                self.activityIndicatorView.stopAnimating()
                                                                
                                                                let alertVC = UIAlertController.init(title: "Echec", message:"La tokénization a échoué ! (\(parsedResponseKey)" , preferredStyle: .alert)
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
