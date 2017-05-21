import UIKit

class MinutesPickerCell: UITableViewCell {
    
    
    //MARK: - Initializers 
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        
    }
    required init?(coder aDecoder: NSCoder) {
        
        
        fatalError("error")
    }
    
    //MARK: - UI
    
    let label: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let Button: UIButton = {
        let button = UIButton()
        button.setTitle("5 Minutes", for: .normal)
        button.setTitleColor(UIColor(red: 0, green: 122/255, blue: 1, alpha: 1), for: .normal)
        return button
    }()
    
    func setupViews(){
        
        
        addSubview(Button)
        addSubview(label)
        
        addConstraintsWithVFL(views: label, VFL: "V:|[v0]|")
        addConstraintsWithVFL(views: label, VFL: "H:|-16-[v0]")
        
        addConstraintsWithVFL(views: Button, VFL: "V:|[v0]|")
        addConstraintsWithVFL(views: Button, VFL: "H:[v0]-16-|")
    }
    
}
