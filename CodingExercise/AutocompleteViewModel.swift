//
//  AutocompleteViewModel.swift
//  CodingExercise
//
//  Copyright © 2018 slack. All rights reserved.
//

import Foundation

struct ConstantNames {
    static let fileName = "blacklist"
    static let extensionForFile = "txt"
}

protocol AutocompleteViewModelDelegate: class {
    func usersDataUpdated()
    func popAlertWithTitle(title:String)
}

// MARK: - Interfaces
protocol AutocompleteViewModelInterface {
    /*
     * Fetches users from that match a given a search term
     */
    func fetchUserData(_ searchTerm: String?, completionHandler: @escaping (_ users:[UserSearchResult], _ error: Error?) -> Void)

    /*
     * Gets the blacklist in dictionary
     */
    func getBlacklist()
    
    /*
     * Checks if the search term is prefixed by anything in the blacklist
     */
    func blacklistCheck(text: String?) -> Bool

    /*
     * Updates Blacklist according to rules mentioned.
     */
    func addToBlacklist(text: String?)

    /*
     * Updates usernames according to given update string.
     */
    func updateSearchText(text: String?)

    /*
    * Returns a username at the given position.
    */
    func username(at index: Int) -> UserSearchResult

    /*
     * Returns the count of the current usernames array.
     */
    func usernamesCount() -> Int

    /*
     Delegate that allows to send data updates through callback.
 */
    var delegate: AutocompleteViewModelDelegate? { get set }
}

class AutocompleteViewModel: AutocompleteViewModelInterface {
    private let resultsDataProvider: UserSearchResultDataProviderInterface
    private var userData: [UserSearchResult] = []
    public weak var delegate: AutocompleteViewModelDelegate?
    private var inBlacklist = false
    private var presentText : String?
    
    init(dataProvider: UserSearchResultDataProviderInterface) {
        self.resultsDataProvider = dataProvider
    }

    func getBlacklist(){
            // Specify the path to the blacklist file.
        let dir = try? FileManager.default.url(for: .documentDirectory,
                                               in: .userDomainMask, appropriateFor: nil, create: true)
        
        if let fileURL = dir?.appendingPathComponent(ConstantNames.fileName).appendingPathExtension(ConstantNames.extensionForFile) {

                // Load the file contents as a string.
                let blacklistString = try! String(contentsOfFile: fileURL.path, encoding: String.Encoding.utf8)
                // Append the words to dataArray array by breaking them using the line change character.
                var dataArray = blacklistString.components(separatedBy: "\n")
                dataArray.popLast()
                
                GlobalData.blackList = Dictionary(grouping: dataArray, by: {$0.first!})
                
            }
    }
    
    func blacklistCheck(text: String?) -> Bool{
        guard let text = text else {
            return false
        }
        if (text != "" && (GlobalData.blackList.keys.contains(text.first!))){
            for i in 0...text.count{
                let prefText = text.prefix(i)
                if (GlobalData.blackList[text.first!]!.contains(String(prefText))){
                    inBlacklist = true
                    return inBlacklist
                }
            }
        }
        inBlacklist = false
        return false
    }
    
    func addToBlacklist(text: String?) {
        guard let text = text else {return}
        if (text != ""){
        if ( GlobalData.blackList.keys.contains(text.first!)){
            GlobalData.blackList[text.first!]!.append(text)
        }else{
            GlobalData.blackList[text.first!] = [text]
        }
        
        let dir = try? FileManager.default.url(for: .documentDirectory,
                                               in: .userDomainMask, appropriateFor: nil, create: true)
        let data = GlobalData.blackList.values
        // Convert data to flat map and then to string separated by new line character
        let str = data.flatMap({$0}).joined(separator: "\n")
        if let fileURL = dir?.appendingPathComponent(ConstantNames.fileName).appendingPathExtension(ConstantNames.extensionForFile) {

        do{
            if (FileManager.default.fileExists(atPath: fileURL.path)){
                try FileManager.default.removeItem(at: fileURL)
                try str.write(to: fileURL, atomically: true, encoding: .utf8)
            }else{
                try str.write(to: fileURL, atomically: true, encoding: .utf8)
            }
        }catch{
            print(error)
        }
            }
        }
    }
    
    func updateSearchText(text: String?) {
        //To avoid presenting when text is Empty
        self.presentText = text
        
        if text! != ""{
            if GlobalData.blackList != nil && (self.blacklistCheck(text: (text)?.lowercased())){
                //Search String present in Blacklist
                self.userData = []
                self.delegate?.usersDataUpdated()
                self.delegate?.popAlertWithTitle(title: errorMessage(passedEnum: .isInBlackList))
            }else{
                 self.fetchUserData(text) { [weak self] userData,error in
                    if error != nil{
                        DispatchQueue.main.async {
                            if((error?.localizedDescription.contains("Internet"))!){
                                self?.delegate?.popAlertWithTitle(title: (error?.localizedDescription)!)
                            }
                        }
                    }else{
                        DispatchQueue.main.async {
                            if(userData.count == 0 && (error == nil)){
                                self?.userData = []
                                self?.delegate?.usersDataUpdated()
                                self?.addToBlacklist(text: text?.lowercased())
                                self?.delegate?.popAlertWithTitle(title: errorMessage(passedEnum: .addToBlacklist))

                            }else if(!(self?.inBlacklist)! && self?.presentText! != ""){
                                self?.userData = userData
                                self?.delegate?.usersDataUpdated()
                            }
                        }
                    }
                }
            }
        }else {
            self.userData = []
            self.delegate?.usersDataUpdated()
        }
    }
    
    func usernamesCount() -> Int {
        return userData.count
    }

    func username(at index: Int) -> UserSearchResult {
        return userData[index]
    }

    func fetchUserData(_ searchTerm: String?, completionHandler: @escaping (_ users:[UserSearchResult], _ error: Error?) -> Void) {
        guard let term = searchTerm, !term.isEmpty else {
            completionHandler([],nil)
            return
        }

        self.resultsDataProvider.fetchUsers(term) { users,error in
            completionHandler(users.map { $0 },error)
        }
    }
}
