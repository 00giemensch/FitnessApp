import UIKit

struct StatisticsModuleFactory {
    static func makeStatisticsModule(
        coordinator: IAppCoordinator,
        workoutManager: WorkoutManagerProtocol,
        goalManager: GoalManagerProtocol
    ) -> UIViewController {
        let viewModel = StatisticsViewModel(
            coordinator: coordinator,
            workoutManager: workoutManager,
            goalManager: goalManager
        )
        let controller = StatisticsViewController(viewModel: viewModel)
        controller.coordinator = coordinator
        return controller
    }
}

