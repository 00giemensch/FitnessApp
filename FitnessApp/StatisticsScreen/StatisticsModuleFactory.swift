import UIKit

struct StatisticsModuleFactory {
    static func makeStatisticsModule(
        coordinator: IAppCoordinator,
        workoutRepository: WorkoutRepositoryProtocol,
        goalRepository: GoalRepositoryProtocol
    ) -> UIViewController {
        let viewModel = StatisticsViewModel(
            coordinator: coordinator,
            workoutRepository: workoutRepository,
            goalRepository: goalRepository
        )
        let controller = StatisticsViewController(viewModel: viewModel)
        controller.coordinator = coordinator
        return controller
    }
}

