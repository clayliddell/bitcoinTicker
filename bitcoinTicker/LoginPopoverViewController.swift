//
//  LoginPopoverViewController.swift
//  bitcoinTicker
//
//  Created by Clay Liddell on 3/13/18.
//  Copyright © 2018 Clay Liddell. All rights reserved.
//

//
//  LoginPopoverViewController.swift
//  CableCount
//
//  Created by Clay LIddell on 7/17/17.
//  Copyright © 2017 Clay LIddell. All rights reserved.
//

import UIKit

class SettingsPopoverViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let nativeCurrencies = ["USD", "EUR", "GDB", "JPY"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return nativeCurrencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let defaults = UserDefaults.standard
        
        defaults.set(nativeCurrencies[row], forKey: "nativeCurrency")
    }
    
    func pickerView(_ pickerView: UIPickerView,
                             titleForRow row: Int,
                             forComponent component: Int) -> String? {
        return nativeCurrencies[row]
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

