import UIKit

enum ChartPeriod: Int, CaseIterable {
    case day = 0
    case week = 1
    case month = 2
    case sixMonths = 3
    case year = 4
    
    var title: String {
        switch self {
        case .day: return "Д"
        case .week: return "Н"
        case .month: return "М"
        case .sixMonths: return "6М"
        case .year: return "Г"
        }
    }
}

class BestResultChartView: UIView {
    
    private var allWorkouts: [Workout] = []
    private var dataPoints: [(date: Date, value: Int)] = []
    private var periodWorkouts: [Workout] = []
    private var currentPeriod: ChartPeriod = .week
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        clipsToBounds = true
    }
    
    func updateData(workouts: [Workout]) {
        allWorkouts = workouts.sorted { $0.date < $1.date }
        filterDataForPeriod(currentPeriod)
        setNeedsDisplay()
    }
    
    func setPeriod(_ period: ChartPeriod) {
        currentPeriod = period
        filterDataForPeriod(period)
        setNeedsDisplay()
    }
    
    func getPeriod() -> ChartPeriod {
        return currentPeriod
    }
    
    func getTotalValue() -> Int {
        return periodWorkouts.reduce(0) { $0 + $1.totalRepetitions }
    }
    
    func getPeriodString() -> String {
        guard !dataPoints.isEmpty else { return "" }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        
        let startDate = dataPoints.first!.date
        let endDate = dataPoints.last!.date
        
        switch currentPeriod {
        case .day:
            formatter.dateFormat = "d MMM yyyy г"
            return formatter.string(from: startDate)
        case .week:
            formatter.dateFormat = "d"
            let startDay = formatter.string(from: startDate)
            formatter.dateFormat = "d MMM yyyy"
            let endString = formatter.string(from: endDate)
            let endDay = endString.components(separatedBy: " ").first ?? ""
            formatter.dateFormat = "MMM"
            let month = formatter.string(from: endDate)
            formatter.dateFormat = "yyyy"
            let year = formatter.string(from: endDate)
            return "\(startDay)-\(endDay) \(month) \(year) г"
        case .month:
            formatter.dateFormat = "d MMM"
            let startString = formatter.string(from: startDate)
            formatter.dateFormat = "d MMM yyyy"
            let endString = formatter.string(from: endDate)
            return "\(startString)-\(endString) г"
        case .sixMonths, .year:
            formatter.dateFormat = "d MMM"
            let startString = formatter.string(from: startDate)
            formatter.dateFormat = "d MMM yyyy"
            let endString = formatter.string(from: endDate)
            return "\(startString)-\(endString) г"
        }
    }
    
    private func filterDataForPeriod(_ period: ChartPeriod) {
        let calendar = Calendar.current
        let now = Date()
        var startDate: Date
        var endDate: Date
        
        switch period {
        case .day:
            startDate = calendar.startOfDay(for: now)
            endDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? startDate
            periodWorkouts = allWorkouts.filter { calendar.startOfDay(for: $0.date) >= startDate && calendar.startOfDay(for: $0.date) < endDate }
            dataPoints = generateDataPointsForRange(from: startDate, to: endDate, calendar: calendar)
            
        case .week:
            startDate = calendar.date(byAdding: .day, value: -6, to: now) ?? now
            startDate = calendar.startOfDay(for: startDate)
            endDate = calendar.date(byAdding: .day, value: 1, to: now) ?? now
            endDate = calendar.startOfDay(for: endDate)
            periodWorkouts = allWorkouts.filter { calendar.startOfDay(for: $0.date) >= startDate && calendar.startOfDay(for: $0.date) < endDate }
            dataPoints = generateDataPointsForRange(from: startDate, to: endDate, calendar: calendar)
            
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            startDate = calendar.startOfDay(for: startDate)
            endDate = calendar.date(byAdding: .day, value: 1, to: now) ?? now
            endDate = calendar.startOfDay(for: endDate)
            periodWorkouts = allWorkouts.filter { calendar.startOfDay(for: $0.date) >= startDate && calendar.startOfDay(for: $0.date) < endDate }
            dataPoints = generateDataPointsForRange(from: startDate, to: endDate, calendar: calendar)
            
        case .sixMonths:
            startDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
            startDate = calendar.startOfDay(for: startDate)
            endDate = calendar.date(byAdding: .day, value: 1, to: now) ?? now
            endDate = calendar.startOfDay(for: endDate)
            periodWorkouts = allWorkouts.filter { calendar.startOfDay(for: $0.date) >= startDate && calendar.startOfDay(for: $0.date) < endDate }
            dataPoints = generateDataPointsForRange(from: startDate, to: endDate, calendar: calendar)
            
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            startDate = calendar.startOfDay(for: startDate)
            endDate = calendar.date(byAdding: .day, value: 1, to: now) ?? now
            endDate = calendar.startOfDay(for: endDate)
            periodWorkouts = allWorkouts.filter { calendar.startOfDay(for: $0.date) >= startDate && calendar.startOfDay(for: $0.date) < endDate }
            dataPoints = generateDataPointsForRange(from: startDate, to: endDate, calendar: calendar)
        }
    }
    
    private func generateDataPointsForRange(from startDate: Date, to endDate: Date, calendar: Calendar) -> [(date: Date, value: Int)] {
        var points: [(date: Date, value: Int)] = []
        var currentDate = startDate
        
        let workoutsByDate = Dictionary(grouping: allWorkouts) { workout in
            calendar.startOfDay(for: workout.date)
        }
        
        while currentDate < endDate {
            let dayStart = calendar.startOfDay(for: currentDate)
            if let workouts = workoutsByDate[dayStart], !workouts.isEmpty {
                let bestResult = workouts.map { $0.bestResult }.max() ?? 0
                points.append((date: dayStart, value: bestResult))
            } else {
                points.append((date: dayStart, value: 0))
            }
            
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        
        return points
    }
    
    override func draw(_ rect: CGRect) {
        guard !dataPoints.isEmpty else {
            drawEmptyState(in: rect)
            return
        }
        
        let context = UIGraphicsGetCurrentContext()
        context?.clear(rect)
        
        let padding: CGFloat = 20
        let chartRect = rect.inset(by: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
        
        drawBars(in: chartRect, context: context)
        drawLabels(in: chartRect, context: context)
    }
    
    private func drawEmptyState(in rect: CGRect) {
        let text = "Нет данных для графика"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.secondaryLabel
        ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedString.size()
        let textRect = CGRect(
            x: (rect.width - textSize.width) / 2,
            y: (rect.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        attributedString.draw(in: textRect)
    }
    
    private func drawBars(in rect: CGRect, context: CGContext?) {
        guard let context = context, !dataPoints.isEmpty else { return }
        
        let maxValue = max(dataPoints.map { $0.value }.max() ?? 1, 1)
        let barCount = dataPoints.count
        let barSpacing: CGFloat = 1
        let availableWidth = rect.width - (CGFloat(barCount - 1) * barSpacing)
        let barWidth = max(1, min(3, availableWidth / CGFloat(barCount)))
        
        for (index, dataPoint) in dataPoints.enumerated() {
            let x = rect.minX + CGFloat(index) * (barWidth + barSpacing)
            let normalizedValue = CGFloat(dataPoint.value) / CGFloat(maxValue)
            let barHeight = rect.height * normalizedValue
            
            if barHeight > 0 {
                let barRect = CGRect(
                    x: x,
                    y: rect.maxY - barHeight,
                    width: barWidth,
                    height: barHeight
                )
                
                let roundedPath = UIBezierPath(roundedRect: barRect, cornerRadius: barWidth / 2)
                context.setFillColor(UIColor.systemBlue.withAlphaComponent(0.8).cgColor)
                context.addPath(roundedPath.cgPath)
                context.fillPath()
            }
        }
    }
    
    private func drawLabels(in rect: CGRect, context: CGContext?) {
        guard !dataPoints.isEmpty else { return }
        
        let maxValue = max(dataPoints.map { $0.value }.max() ?? 1, 1)
        
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .medium),
            .foregroundColor: UIColor.secondaryLabel
        ]
        
        let maxValueText = "\(maxValue)"
        let maxValueAttributed = NSAttributedString(string: maxValueText, attributes: valueAttributes)
        let maxValueSize = maxValueAttributed.size()
        maxValueAttributed.draw(at: CGPoint(x: rect.maxX - maxValueSize.width - 8, y: rect.minY - maxValueSize.height / 2))
        
        let zeroText = "0"
        let zeroAttributed = NSAttributedString(string: zeroText, attributes: valueAttributes)
        let zeroSize = zeroAttributed.size()
        zeroAttributed.draw(at: CGPoint(x: rect.minX - zeroSize.width - 8, y: rect.maxY - zeroSize.height / 2))
    }
}

