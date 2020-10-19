//
//  StatusViewController.swift
//  Whoosh QR Scanner
//
//  Created by Artem Kayumov on 16.10.2020.
//

import SnapKit
import UIKit

class StatusViewController: UIViewController {

    // MARK: - Private properties
    
    private let scooterNumber: String
    private let heading = UILabel()
    private let status = UILabel()
    private let comment = UILabel()

    // MARK: - Init
    
    init(_ scooterNumber: String) {
        self.scooterNumber = scooterNumber
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    deinit {
        Configuration.scooter.removeObserver(self)
    }
    
    // MARK: - Configuration
    
    private func configure() {
        configureRequest()
        configureHeading()
        configureStatus()
        configureComment()
        setupTexts()
        subscribe()
    }
    
    // MARK: - Subscribe
    
    private func subscribe() {
        Configuration.scooter.addObserver(self) { [weak self] (_, _) in
            self?.setupTexts()
        }
    }

    // MARK: - Private methods
    
    private func configureRequest() {
        let service = NetworkService()
        service.request(scooterNumber)
    }
    
    private func configureHeading() {
        heading.text = scooterNumber
        heading.textAlignment = .center
        heading.textColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        heading.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        view.addSubview(heading)
        heading.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(100.0)
        }
    }
    
    private func configureStatus() {
        view.addSubview(status)
        status.textColor = .white
        status.numberOfLines = 0
        status.textAlignment = .left
        status.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.snp.centerY).offset(-100.0)
            make.left.equalToSuperview().offset(50.0)
            make.right.equalToSuperview().offset(-50.0)
        }
    }
    
    private func configureComment() {
        view.addSubview(comment)
        comment.textColor = .white
        comment.numberOfLines = 0
        comment.textAlignment = .left
        comment.snp.makeConstraints { (make) in
            make.top.equalTo(status.snp.bottom).offset(50.0)
            make.left.equalToSuperview().offset(50.0)
            make.right.equalToSuperview().offset(-50.0)
        }
    }
    
    private func setupTexts() {
        guard let scooter = Configuration.scooter.value else { return }
        status.text = "Статус самоката: \(scooter.status)"
        comment.text = "Комментарий: \(scooter.comments)"
    }
}
