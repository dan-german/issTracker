import UIKit

class PassTimeCell: UITableViewCell {
    
    
    //MARK: - Initializers
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        
        fatalError("error")
    }
    
    //MARK: - UI
    
    let riseTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "↑ 12:00 PM"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let fallTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "↓ 12:05 PM"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(white: 0, alpha: 0.5)
        return label
    }()
    
    let emojiLabel = UILabel()
    
    let progressBar: UIProgressView = {
        let bar = UIProgressView()
        bar.progress = 0
        bar.layer.zPosition = -1
        bar.trackTintColor = UIColor(white: 1, alpha: 0)
        bar.progressTintColor = UIColor(red: 0.60, green: 1.00, blue: 0.60, alpha: 1.0)
        return bar
    }()
    
    //MARK: - 
    
    private func setupViews(){
        
        
        addSubview(riseTimeLabel)
        addSubview(fallTimeLabel)
        addSubview(emojiLabel)
        addSubview(progressBar)
        
        addConstraintsWithVFL(views: riseTimeLabel, VFL: "H:|-16-[v0]")
        addConstraintsWithVFL(views: riseTimeLabel, fallTimeLabel, VFL: "V:|[v0][v1]|")
        
        addConstraintsWithVFL(views: fallTimeLabel, VFL: "H:|-16-[v0]")
        
        addConstraintsWithVFL(views: emojiLabel, VFL: "H:[v0]-|")
        addConstraintsWithVFL(views: emojiLabel, VFL: "V:|[v0]|")
        
        addConstraintsWithVFL(views: progressBar, VFL: "V:|[v0]|")
        addConstraintsWithVFL(views: progressBar, VFL: "H:|[v0]|")
    }
}
