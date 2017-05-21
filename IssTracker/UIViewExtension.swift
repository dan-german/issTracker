import UIKit

extension UIView {
    

    func addConstraintsWithVFL(views: UIView... , VFL: String){
        
        
        var viewsDictionary = [String: UIView]()
        
        for(i, view) in views.enumerated(){
            
            let key = "v\(i)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: VFL, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}
