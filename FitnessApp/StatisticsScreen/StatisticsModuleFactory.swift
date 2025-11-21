import UIKit

struct StatisticsModuleFactory {
    static func makeStatisticsModule(coordinator: IAppCoordinator) -> UIViewController {
        let viewModel = StatisticsViewModel(coordinator: coordinator)
        let controller = StatisticsViewController(viewModel: viewModel)
        controller.coordinator = coordinator
        return controller
    }
}

