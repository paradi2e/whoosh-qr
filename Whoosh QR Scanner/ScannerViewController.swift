//
//  ScannerViewController.swift
//  Whoosh QR Scanner
//
//  Created by Artem Kayumov on 16.10.2020.
//

import AVFoundation
import UIKit

class ScannerViewController: UIViewController {
    
    // MARK: - Public properties
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - Private properties
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    // MARK: - Lifecycle ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        checkInternet()
        checkAutorization()
        configureSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    // MARK: - Private methods
    
    /// Проверка доступа к интернету.
    private func checkInternet() {
        if (Reachability.isConnectedToNetwork() != true) {
            let ac = UIAlertController(
                title: "Нет доступа к Интернету",
                message: "К сожалению, приложение работает только при наличии доступа к сети Интернет, подключитесь к сети и повторите попытку",
                preferredStyle: .alert
            )
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    /// Конфигурация сессии захвата видео
    private func configureSession() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    /// Алёрт в случае отсутствии камеры у устройства
    private func failed() {
        let ac = UIAlertController(title: "Сканирование не поддерживается", message: "Упс, видимо у тебя нету камеры. Нужно устройство с камерой", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    /// При успешном считывании QR-кода
    /// - Parameter code: стринговое содержимое QR-кода
    private func success(code: String) {
        let wordToRemove = Configuration.filterString
        var number = code
        // удаляем из строки всё, кроме кода самоката
        if let range = number.range(of: wordToRemove) {
            number.removeSubrange(range)
        }
        Configuration.scooterNumber = number
        let ac = UIAlertController(title: "Самокат обнаружен", message: "Это самокат номер \(number)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cканировать другой QR-code", style: .cancel, handler: { [weak self] (_) in
            ac.dismiss(animated: true, completion: nil)
            self?.captureSession.startRunning()
        }))
        ac.addAction(UIAlertAction(title: "Получить статус?", style: .default, handler: { [weak self] (_) in
            self?.openStatusController()
        }))
        present(ac, animated: true)
    }
    
    /// Открывается контроллер с двумя лейблами о состоянии самоката
    private func openStatusController() {
        let statusController = StatusViewController()
        navigationController?.pushViewController(statusController, animated: true)
    }
    
    private func checkAutorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (_) in
                return
            }
        case .denied, .restricted:
            let ac = UIAlertController(title: "Необходим доступ к камере", message: "Приложение работает только при наличии доступа к камере, перейдите в настройки и откройте доступ к камере!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Перейти в настройки", style: .default, handler: { [weak self] (_) in
                self?.openSettings()
            }))
            present(ac, animated: true)
        @unknown default:
            fatalError()
        }
    }
    
    /// Метод по переходу в настройки для получения доступа к камере
    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString)
        else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            if !stringValue.contains(Configuration.filterString) {
                let ac = UIAlertController(title: "Не тот QR-code", message: "Я умею обрабатывать только QR коды компании Whoosh", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Cканировать другой QR-code", style: .default, handler: { [weak self] (_) in
                    self?.captureSession.startRunning()
                }))
                present(ac, animated: true)
            }
            success(code: stringValue)
        }
    }
}
