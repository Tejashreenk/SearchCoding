# ios-serachcode-exercise

# Changes in AutocompleteViewController
# Extensions Added

1.     func popAlertWithTitle(title:String)
    a. Extension to AutocompleteViewController.
    b. Simple Alert with title popped when required (e.g Incase of errors, Incase of activities related to Blacklist etc)
    c. Used in various places hence an extension becomes useful.
    
2.     func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit)
    a. Extension to UIImageView.
    b. Downloads images from url asynchronously.
    c. Stores the downloaded images in cache so as to avoid url call for downloading of images already downloaded. Thus the response time reduces.
    d. Used in various places hence an extension becomes useful.

# Changes in UserSearchResult

1. Added fields in UserSearchResult to store values of avatar_url, display_name, id, username
2. Added enum for projectError to help displaying error to the user in the form of popped Alert
3.  func errorMessage(passedEnum:projectError) -> (String)  added to pass the title to error popup alert as per the type of error declared in the enum.

# Changes in SlackAPIService
1. Passing the error as well in order to understand the error and take actions accordingly.
    (eg. The text should not be added in the balcklist whenthe task is cancelled and no data but should be added when no data received on the completion of the request, Intimate the errors to users)

# Changes in AutocompleteViewModel
1.     func getBlacklist()
    a. Gets the blacklist in dictionary.
    b. Advantage of getting the list stored in local store is that it saves time in the look up
    c.  All blacklist words starting with 'a' stored in array in the dictionary with key is 'a'. Similarly for 'b' etc
        Advantage of Dictionary over array is that only the array whose key matches the first character of the input string is browsed through. This saves the look up time.
        e.g. when the user types 'gol' only the words with first charcter as 'g' 
            [gl, ge, gal, gar, gat] will be browsed through and not the entire blacklist.

2.     func blacklistCheck(text: String?) -> Bool
    a. Checks if the search term is prefixed by anything in the blacklist

3.     func addToBlacklist(text: String?)
    a. Updates Blacklist according to rules mentioned.

4.  Return type of some functions changed in order to return 'UserSearchResult' over 'String'

5. Function Names changed to convey the meaning as per the changed functionality of the functions
      func fetchUserNames(_ searchTerm: String?, completionHandler: @escaping ([String]) -> Void) changed to
      func fetchUserData(_ searchTerm: String?, completionHandler: @escaping (_ users:[UserSearchResult], _ error: Error?) -> Void)

# Added Files
1.    UserTableViewCell.swift
        Details of custom Table View Cell
        
2.    UserTableViewCell.xib
        Xib for custom Table View Cell
        
3.    GlobalData.swift
        Class contains the Global Data required throughout the App. In this case 'Blacklist'

# Unit Test Cases added
1. Simple Unit Test Cases added to check if the File conforms to the delegate.
 
