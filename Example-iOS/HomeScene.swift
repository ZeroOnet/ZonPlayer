//
//  HomeScene.swift
//  Example-iOS
//
//  Created by 李文康 on 2023/11/7.
//

@_exported import ZonPlayer

final class HomeScene: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        _configureSubviews()
        _loadData()
    }

    private lazy var _tableView: UITableView = {
        let result = UITableView()
        result.backgroundColor = .white
        result.translatesAutoresizingMaskIntoConstraints = false
        result.dataSource = self
        result.delegate = self
        return result
    }()

    private var _items: [_Item] = []
    private let _cellID = String(describing: UITableViewCell.self)
}

extension HomeScene: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _items[indexPath.row].action()
    }
}

extension HomeScene: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        _items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = _items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: _cellID) 
            ?? UITableViewCell(style: .default, reuseIdentifier: _cellID)
        cell.textLabel?.text = item.title
        return cell
    }
}

extension HomeScene {
    private func _configureSubviews() {
        title = "ZonPlayer"
        view.backgroundColor = .white
        view.addSubview(_tableView)
        NSLayoutConstraint.activate([
            _tableView.topAnchor.constraint(equalTo: view.topAnchor),
            _tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            _tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            _tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        navigationItem.rightBarButtonItem = .init(
            title: "Clean Cache",
            style: .plain,
            target: self,
            action: #selector(_cleanCacheAction)
        )
    }

    @objc
    private func _cleanCacheAction() {
        ZPC.DefaultFileStorage().deleteAll()
    }

    private func _loadData() {
        _items = [
            _Item(title: "Video Player") { [weak self] in
                guard let self else { return }
                let scene = self._storyboardScene(with: "VideoPlayerScene")
                self.navigationController?.pushViewController(scene, animated: true)
            },
            _Item(title: "Audio Player") { [weak self] in
                guard let self else { return }
                let scene = self._storyboardScene(with: "AudioPlayerScene")
                self.navigationController?.pushViewController(scene, animated: true)
            }
        ]

        _tableView.reloadData()
    }

    private func _storyboardScene(with id: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        return storyboard.instantiateViewController(withIdentifier: id)
    }
}

extension HomeScene {
    fileprivate struct _Item {
        let title: String
        let action: () -> Void
    }
}
