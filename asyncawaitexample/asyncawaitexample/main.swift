import Foundation

struct MyDataModel {}

struct MyViewModel {}

struct MyDomainModel {}

@MainActor
protocol MyView: AnyObject {
    func update(with viewModel: MyViewModel)
}

@MainActor
protocol MyPresenter {
    func viewDidLoad()
}

final class MyPresenterImpl: MyPresenter {
    var task: Task<Void, Error>?
    weak var view: MyView?
    var interactor: MyInteractor!

    func viewDidLoad() {
        task = Task(priority: .background) { [weak self] in
            guard let self else { return }
            let result = await self.interactor.doWork(data: Data())
            let viewModel = await self.makeViewModel(from: result)
            self.view?.update(with: viewModel)
        }
    }

    func viewDidDisappear() {
        task?.cancel()
        task = nil
    }

    func makeViewModel(from: MyDomainModel) async -> MyViewModel {
        .init()
    }
}

protocol MyService {
    func fetchData() async throws -> MyDataModel
}

final class MyServiceImpl: MyService {
    func fetchData() async throws -> MyDataModel {
        try await Task.sleep(for: .seconds(10))
        return .init()
    }
}

protocol MyInteractor {
    func doWork(data: Data) async -> MyDomainModel
}

final class MyInteractorImpl: MyInteractor {
    var service: MyService!

    func doWork(data: Data) async -> MyDomainModel {
        do {
            let data = try await service.fetchData()
            return .init()
        } catch {
            // handle cancellation error here, or on layers below
            print("cancelled")
            return .init()
        }
    }
}
