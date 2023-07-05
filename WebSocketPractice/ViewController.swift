//
//  ViewController.swift
//  WebSocketPractice
//
//  Created by 이명진 on 2023/07/05.
//

import UIKit
import Then
import SnapKit
import SwiftyJSON

final class ViewController: UIViewController {
    
    private var priceLabel: UILabel = UILabel().then {
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 25, weight: .bold)
        $0.text = "0"
    }
    
    private var connectButton: UIButton = UIButton().then {
        $0.setTitle("연결하기", for: .normal)
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 12
    }
    
    private var disConnectButton: UIButton = UIButton().then {
        $0.setTitle("연결해제", for: .normal)
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 12
    }
    
    private var messageButton: UIButton = UIButton().then {
        $0.setTitle("매세지 보내기", for: .normal)
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 12
    }
    
    var websocketTask: URLSessionWebSocketTask? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setConstraints()
    }
    
    private func configureUI() {
        [priceLabel, connectButton, disConnectButton, messageButton].forEach { view.addSubview($0) }
        view.backgroundColor = .white
        connectButton.addTarget(self, action: #selector(connect), for: .touchUpInside)
        disConnectButton.addTarget(self, action: #selector(disconnect), for: .touchUpInside)
        messageButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }
    
    private func setConstraints() {
        priceLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        connectButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(48)
            make.bottom.equalTo(disConnectButton.snp.top).offset(-12)
        }
        
        disConnectButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(48)
            make.bottom.equalTo(messageButton.snp.top).offset(-12)
        }
        
        messageButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(48)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
    }
    
    @objc private func connect() {
        disconnect()
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: OperationQueue())
        guard let url = URL(string: "wss://ws.dogechain.info/inv") else { return }
        websocketTask = session.webSocketTask(with: url)
        websocketTask?.resume()
        receiveMessage()
    }
    
    @objc private func disconnect() {
        websocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    @objc private func sendMessage() {
        let dictionary = ["op": "price_sub"]
        guard let jsonString = JSON(dictionary).rawString() else { return }
        
        let messageToSend = URLSessionWebSocketTask.Message.string(jsonString)
        
        websocketTask?.send(messageToSend, completionHandler: { err in
            print(err)
        })
    }
    
    private func receiveMessage() {
        websocketTask?.receive(completionHandler: { [weak self] (result: Result<URLSessionWebSocketTask.Message, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(.string(let message)):
                print(#fileID, #function, #line, "- msg: \(message)")
                
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(SocketModel.self, from: Data(message.utf8))
                    
                    DispatchQueue.main.async {
                        self.priceLabel.text = result.msg.value
                    }
                } catch {
                    print("error: \(error.localizedDescription)")
                }
                
                self.receiveMessage()
            case .success(.data(let data)):
                print(#fileID, #function, #line, "- data: \(data)")
            case .success(let success):
                print(#fileID, #function, #line, "- success: \(success)")
            case .failure(let failure):
                print(#fileID, #function, #line, "- failure: \(failure)")
            
            }
        })
    }
    
}

extension ViewController: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        
        print("연결됨", session)
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        
        print("연결 해제됨", session, closeCode, reason)
    }
}

