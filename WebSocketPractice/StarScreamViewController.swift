//
//  StarScreamViewController.swift
//  WebSocketPractice
//
//  Created by 이명진 on 2023/07/05.
//

import UIKit
import Starscream
import SwiftyJSON

final class StarScreamViewController: UIViewController {
    
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
    
    var isConnected: Bool = false
    var webSocket: WebSocket? = nil
    
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
        
        guard let url = URL(string: "wss://ws.dogechain.info/inv") else { return }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        webSocket = WebSocket(request: request)
        webSocket?.delegate = self
        webSocket?.connect()
    }
    
    @objc private func disconnect() {
        webSocket?.disconnect()
    }
    
    @objc private func sendMessage() {
        let dictionary = ["op": "price_sub"]
        guard let jsonString = JSON(dictionary).rawString() else { return }
        
        webSocket?.write(string: jsonString, completion: {
            print("sendMessage")
        })
        
    }
    
    private func handleError(_ error: Error?) {
        print("error: \(error)")
    }
}

extension StarScreamViewController: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(SocketModel.self, from: Data(string.utf8))
                
                DispatchQueue.main.async {
                    self.priceLabel.text = result.msg.value
                }
            } catch {
                print("error: \(error.localizedDescription)")
            }
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
            print("연결이 해제됨")
        case .error(let error):
            isConnected = false
            handleError(error)
        }
    }
}
