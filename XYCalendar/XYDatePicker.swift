//
//  CalendarView.swift
//  XYCalendar
//
//  Created by lxy on 2020/12/16.
//

import Foundation

typealias YearAndMonthCallback = (String)->Void
typealias DateSelectCallback = (Date?)->Void
let horizonSpace: CGFloat = 6
let marginSpace: CGFloat = 20



public class XYDatePicker: UIView {
    lazy var calendarView: XYCalendarView = {
        let view = XYCalendarView(startDate: startDate, endDate: endDate)
        return view
    }()
    
    let startDate: Date
    let endDate: Date
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    lazy var weeksStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = horizonSpace
        return stackView
    }()
    
    public init(startDate: Date = Date().previousMonth(),
                endDate: Date = Date().nextMonth().nextMonth()) {
        self.startDate = startDate
        self.endDate = endDate
        super.init(frame: CGRect.zero)
        
        setupSubviews()
        addLayout()
        calendarView.yearAndMonthCallback = { [unowned self] str in
            self.titleLabel.text = str
        }
        
        calendarView.dateSelectCallback = { date in
            print("xxxxx: \(date?.year()), \(date?.month()), \(date?.day())")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupSubviews() {
        addSubview(titleLabel)
        addSubview(weeksStackView)
        addSubview(calendarView)
        
        translatesAutoresizingMaskIntoConstraints = false
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        weeksStackView.translatesAutoresizingMaskIntoConstraints = false

        for week in WeekDay.allItem {
            let label = UILabel()
            label.text = week.desc
            label.textAlignment = .center
            label.textColor = .black
            label.font = .systemFont(ofSize: 14, weight: .medium)
            weeksStackView.addArrangedSubview(label)
        }
    }
    
    func addLayout() {
        titleLabel.addConstraint(NSLayoutConstraint(item: titleLabel,
                                                    attribute: .height,
                                                    relatedBy: .equal,
                                                    toItem: nil,
                                                    attribute: .notAnAttribute,
                                                    multiplier: 1,
                                                    constant: 40))
        addConstraints([NSLayoutConstraint(item: titleLabel,
                                           attribute: .left,
                                           relatedBy: .equal,
                                           toItem: self,
                                           attribute: .left,
                                           multiplier: 1,
                                           constant: 0),
                        NSLayoutConstraint(item: titleLabel,
                                           attribute: .top,
                                           relatedBy: .equal,
                                           toItem: self,
                                           attribute: .top,
                                           multiplier: 1,
                                           constant: 0),
                        NSLayoutConstraint(item: titleLabel,
                                           attribute: .right,
                                           relatedBy: .equal,
                                           toItem: self,
                                           attribute: .right,
                                           multiplier: 1,
                                           constant: 0)])
        
        weeksStackView.addConstraint(NSLayoutConstraint(item: weeksStackView,
                                                        attribute: .height,
                                                        relatedBy: .equal,
                                                        toItem: nil,
                                                        attribute: .notAnAttribute,
                                                        multiplier: 1,
                                                        constant: 40))

        addConstraints([NSLayoutConstraint(item: weeksStackView,
                                           attribute: .top,
                                           relatedBy: .equal,
                                           toItem: titleLabel,
                                           attribute: .bottom,
                                           multiplier: 1,
                                           constant: 10),
                        NSLayoutConstraint(item: weeksStackView,
                                           attribute: .left,
                                           relatedBy: .equal,
                                           toItem: self,
                                           attribute: .left,
                                           multiplier: 1,
                                           constant: marginSpace),
                        NSLayoutConstraint(item: weeksStackView,
                                           attribute: .right,
                                           relatedBy: .equal,
                                           toItem: self,
                                           attribute: .right,
                                           multiplier: 1,
                                           constant: -marginSpace),
                        NSLayoutConstraint(item: calendarView,
                                           attribute: .top,
                                           relatedBy: .equal,
                                           toItem: weeksStackView,
                                           attribute: .bottom,
                                           multiplier: 1,
                                           constant: 0),
                        equalAttribute(.left), equalAttribute(.right), equalAttribute(.bottom)])
    }
    
    func equalAttribute(_ attribute: NSLayoutConstraint.Attribute, _ offset: CGFloat = 0) -> NSLayoutConstraint {
        NSLayoutConstraint(item: calendarView,
                           attribute: attribute,
                           relatedBy: .equal,
                           toItem: self,
                           attribute: attribute,
                           multiplier: 1,
                           constant: offset)
    }
}

class XYCalendarView: UIView {
    var dataHandler: DataHandler
    var yearAndMonthCallback: YearAndMonthCallback?
    var dateSelectCallback: DateSelectCallback?
    let flowLayout = CalendarCollectionViewLayout()
    var lastSelectedDate: DateModel?
    var oldXOffset: CGFloat = 0
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.dataSource = self
        view.delegate = self
        view.register(CalendarCell.self, forCellWithReuseIdentifier: "XYCalendarCell")
        view.backgroundColor = .white
        return view
    }()
    
    init(frame: CGRect, dataHandler: DataHandler) {
        self.dataHandler = dataHandler
        super.init(frame: frame)
        setupSubviews()
    }
    
    convenience init(startDate: Date, endDate: Date) {
        let dataHandler = DataHandler(startDate: startDate, endDate: endDate)
        self.init(frame: CGRect.zero, dataHandler: dataHandler)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = frame.size.width
        let height = frame.size.height
        let w = Double(width-horizonSpace*6-marginSpace*2)/7.0
        let h = Double(height-horizonSpace*6)/6.0
        flowLayout.itemSize = CGSize(width: w, height: h)
        flowLayout.pages = dataHandler.totalMonthCount > 3 ? 3 : dataHandler.totalMonthCount
        flowLayout.invalidateLayout()
        adjsutDataStartOffset()
    }
    
    func setupSubviews() {
        addSubview(collectionView)
        addLayout()
    }
    
    func addLayout() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([equalAttribute(.left), equalAttribute(.right),
                        equalAttribute(.top), equalAttribute(.bottom)])
    }
    
    func equalAttribute(_ attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint {
        NSLayoutConstraint(item: collectionView,
                           attribute: attribute,
                           relatedBy: .equal,
                           toItem: self,
                           attribute: attribute,
                           multiplier: 1,
                           constant: 0)
    }
}

extension XYCalendarView: UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataHandler.sourceDatas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6*7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "XYCalendarCell", for: indexPath) as? CalendarCell
        let dateModel = dataHandler.sourceDatas[indexPath.section].dateArray[indexPath.row]
        cell?.label.text = dateModel.dateIndexString
        
        if dateModel.isOutRange {
            cell?.label.textColor = .lightGray
            cell?.label.backgroundColor = .white
        } else {
            if dateModel.isSelected {
                cell?.label.textColor = .white
                cell?.label.backgroundColor = .red
            } else {
                if dateModel.isToday {
                    cell?.label.textColor = .red
                    cell?.label.backgroundColor = .white
                } else {
                    cell?.label.textColor = .black
                    cell?.label.backgroundColor = .white
                }
            }
        }
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dateModel = dataHandler.sourceDatas[indexPath.section].dateArray[indexPath.row]
        guard !dateModel.isOutRange else { return }
        dateModel.isSelected = !dateModel.isSelected
        
        if dateModel.isSelected {
            if let lastSelected = lastSelectedDate {
                lastSelected.isSelected = false
            }
            dateSelectCallback?(dateModel.date)
        } else {
            if let lastSelected = lastSelectedDate {
                lastSelected.isSelected = false
            }
            dateSelectCallback?(nil)
        }
        lastSelectedDate = dateModel
        collectionView.reloadData()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let newXOffset = scrollView.contentOffset.x
        if newXOffset != oldXOffset {
            if newXOffset > oldXOffset {
                let shouldResetOffset = dataHandler.datesMoveForword()
                if !shouldResetOffset {
                    collectionView.reloadData()
                }
                adjsutDataAndOffset(shouldReset: shouldResetOffset)
            } else if newXOffset < oldXOffset {
                let shouldResetOffset = dataHandler.datesMoveBackward()
                if !shouldResetOffset {
                    collectionView.reloadData()
                }
                adjsutDataAndOffset(shouldReset: shouldResetOffset)
            }
        }
    }
    
    func adjsutDataAndOffset(shouldReset: Bool = true) {
        if dataHandler.totalMonthCount > 2 {
            if shouldReset {
                collectionView.contentOffset = CGPoint(x: collectionView.frame.width, y: 0)
            }
        }
        oldXOffset = collectionView.contentOffset.x
        yearAndMonthCallback?(dataHandler.yearString + "年" + dataHandler.monthString + "月")
    }
    
    func adjsutDataStartOffset() {
        if dataHandler.totalMonthCount == 1 {
        } else if dataHandler.totalMonthCount == 2 {
            if dataHandler.shouldStartFromEnd {
                collectionView.contentOffset = CGPoint(x: collectionView.contentSize.width, y: 0)
                oldXOffset = collectionView.contentSize.width
            }
        } else {
            let start = dataHandler.startDate
            let current = dataHandler.currentDate
            let end = dataHandler.endDate
            
            if start >= current || (start<current && start.month() == current.month() && start.year() == current.year()){
                collectionView.contentOffset = CGPoint.zero
            } else if end <= current || (end>current && end.month() == current.month() && end.year() == current.year()) {
                collectionView.contentOffset = CGPoint(x: collectionView.contentSize.width, y: 0)
                oldXOffset = collectionView.contentSize.width
            } else {
                collectionView.contentOffset = CGPoint(x: collectionView.frame.width, y: 0)
                oldXOffset = collectionView.frame.width
            }
        }
        yearAndMonthCallback?(dataHandler.yearString + "年" + dataHandler.monthString + "月")
    }
}

class CalendarCollectionViewLayout: UICollectionViewFlowLayout {
    var layoutAttributes: [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
    var pages: Int = 0
    
    override init() {
        super.init()
        scrollDirection = .horizontal
        minimumLineSpacing = horizonSpace
        minimumInteritemSpacing = 0
        headerReferenceSize = CGSize(width: marginSpace, height: 10)
        footerReferenceSize = CGSize(width: marginSpace, height: 10)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        let numsection = collectionView!.numberOfSections
        layoutAttributes.removeAll()
        for i in 0..<numsection {
            let itemNum = collectionView!.numberOfItems(inSection: i)
            for j in 0..<itemNum {
                let layout = layoutAttributesForItem(at: IndexPath(item: j, section: i))!;
                layoutAttributes.append(layout)
            }
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let original = super.layoutAttributesForItem(at: indexPath)
        let layoutAttribute = original?.copy() as? UICollectionViewLayoutAttributes
        let col = CGFloat(indexPath.row%7)
        let x = col * itemSize.width + marginSpace + horizonSpace*col + (collectionView?.frame.size.width ?? 0)*CGFloat(indexPath.section)
        let row = CGFloat(indexPath.row/7)
        let y = row * itemSize.height + row * horizonSpace
        layoutAttribute?.frame = CGRect(x:x, y:y, width: itemSize.width, height: itemSize.height);
        return layoutAttribute
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.layoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: (collectionView?.frame.size.width ?? 0)*CGFloat(pages), height: collectionView?.frame.size.height ?? 0)
    }
}

class CalendarCell: UICollectionViewCell {
    var label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.textColor = .black
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        addLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addLayout() {
        contentView.addConstraints([equalAttribute(.left), equalAttribute(.right),
                                    equalAttribute(.top), equalAttribute(.bottom)])
    }
    
    func equalAttribute(_ attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint {
        NSLayoutConstraint(item: label,
                           attribute: attribute,
                           relatedBy: .equal,
                           toItem: contentView,
                           attribute: attribute,
                           multiplier: 1,
                           constant: 0)
    }
}

public extension Date {
    func day() -> Int {
        return Calendar.current.component(.day, from: self)
    }
    
    func month() -> Int {
        return Calendar.current.component(.month, from: self)
    }
    
    func year() -> Int {
        return Calendar.current.component(.year, from: self)
    }
    
    func previousMonth() -> Date {
        if let newDate = Calendar.current.date(byAdding: DateComponents(month: -1), to: self) {
            return newDate
        }
        return self
    }
    
    func nextMonth() -> Date {
        if let newDate = Calendar.current.date(byAdding: DateComponents(month: 1), to: self) {
            return newDate
        }
        return self
    }
    
    func getDate(offset: Int) -> Date {
        guard let newDate = Calendar.current.date(byAdding: DateComponents(day: offset), to: self) else {
            fatalError("date out range")
        }
        return newDate
    }
    
    func isMonthEqual(with date: Date) -> Bool {
        return month() == date.month()
    }
}

class DataHandler {
    var sourceDatas: Array<MonthDatasModel> = []
    var currentDate = Date()
    var showMonth: Date
    
    var totalMonthCount: Int {
        return (Calendar.current.dateComponents([.month], from: startDate, to: endDate).month ?? 0) + 1
    }
    
    var previousMonth: Date {
        return showMonth.previousMonth()
    }
    
    var nextMonth: Date {
        return showMonth.nextMonth()
    }
    
    var isPreviousEnd: Bool {
        return startDate.isMonthEqual(with: showMonth.previousMonth())
    }
    
    var isNextEnd: Bool {
        return endDate.isMonthEqual(with: showMonth.nextMonth())
    }
    
    var shouldStartFromStartDate: Bool {
        return startDate >= startOfMonth(by: currentDate)
    }
    
    var shouldStartFromEnd: Bool {
        return endDate <= endOfMonth(by: currentDate)
    }
    
    var startDate: Date
    var endDate: Date
    
    var canMoveForward: Bool {
        return endDate > endOfMonth(by: showMonth)
    }
    
    var canMoveBackward: Bool {
        return startDate < startOfMonth(by: showMonth)
    }
    
    init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
        let cd = Date()
        if startDate > cd {
            self.showMonth = startDate
        } else if endDate < cd {
            self.showMonth = endDate
        } else {
            self.showMonth = cd
        }
        sourceDatas = initialAllDates(by: currentDate)
    }
    
    func firstWeekdayInThisMonth(by date: Date) -> Int {
        let start = startOfMonth(by: date)
        return Calendar.current.component(Calendar.Component.weekday, from: start) - 1
    }
    
    func startOfMonth(by date: Date) -> Date {
        let components = Calendar.current.dateComponents(Set<Calendar.Component>([.year, .month]), from: date)
        let startOfMonth = Calendar.current.date(from: components)!
        return startOfMonth
    }
    
    func endOfMonth(by date: Date) -> Date {
        let calendar = NSCalendar.current
        var components = DateComponents()
        components.month = 1
        components.second = -1
        let endOfMonth =  calendar.date(byAdding: components, to: startOfMonth(by: date))!
        return endOfMonth
    }
    
    func totaldaysInMonth(by date: Date) -> Int {
        return Calendar.current.range(of: .day, in: .month, for: date)?.count ?? 0
    }
    
    func initialAllDates(by date: Date) -> Array<MonthDatasModel> {
        if shouldStartFromStartDate { //从起始日期往后读取
            let firstDates = getAllDatesData(by: startDate)
            if totalMonthCount == 1 {
                //只有一个月
                return [firstDates]
            } else {
                let secondDates = getAllDatesData(by: startDate.nextMonth())
                if totalMonthCount == 2 {
                    //只有两个月
                    return [firstDates, secondDates]
                } else {
                    //三个月以上
                    let thirdDates = getAllDatesData(by: startDate.nextMonth().nextMonth())
                    return [firstDates, secondDates, thirdDates]
                }
            }
        } else {
            if shouldStartFromEnd { //从结束日期往前读取
                let firstDates = getAllDatesData(by: endDate)
                if totalMonthCount == 1 {
                    //只有一个月
                    return [firstDates]
                } else {
                    let secondDates = getAllDatesData(by: endDate.previousMonth())
                    if totalMonthCount == 2 {
                        //只有两个月
                        return [secondDates, firstDates]
                    } else {
                        //三个月以上
                        let thirdDates = getAllDatesData(by: endDate.previousMonth().previousMonth())
                        return [thirdDates, secondDates, firstDates]
                    }
                }
            } else {
                //从当前月开始读取数据
                let firstDates = getAllDatesData(by: currentDate.previousMonth())
                let secondDates = getAllDatesData(by: currentDate)
                let thirdDates = getAllDatesData(by: currentDate.nextMonth())
                return [firstDates, secondDates, thirdDates]
            }
        }
    }
    
    private func getAllDatesData(by date: Date) -> MonthDatasModel {
        
        var dateArray = Array<DateModel>()
        let components = Calendar.current.dateComponents(Set<Calendar.Component>([.year, .month]), from: date)
        var indexDate = Calendar.current.date(from: components)!
        
        let firstWeekday = firstWeekdayInThisMonth(by: indexDate) //周日为0 依次递增
        //需要显示上月的数据
        if firstWeekday>0 {
            for i in 0..<firstWeekday {
                dateArray.append(DateModel(date: indexDate.getDate(offset: i-firstWeekday), isOutRange: true))
            }
        }
        let totalDays = totaldaysInMonth(by: date)
        //当前月可选数据
        for _ in 0..<totalDays {
            dateArray.append(DateModel(date: indexDate))
            if let nextDay = Calendar.current.date(byAdding: DateComponents(day: 1), to: indexDate) {
                indexDate = nextDay
            } else {
                break
            }
        }
        
        //下月不可选数据
        for i in 0..<(6*7-totalDays-firstWeekday) {
            dateArray.append(DateModel(date: indexDate.getDate(offset: i), isOutRange: true))
        }
        return MonthDatasModel(dateArray: dateArray, showMonth: indexDate)
    }
    
    
    func datesMoveForword() -> Bool {
        if totalMonthCount > 2 {
            if showMonth.isMonthEqual(with: startDate) {
                showMonth = nextMonth
                return true
            } else {
                if showMonth.isMonthEqual(with: endDate) {
                    return false
                } else if showMonth.isMonthEqual(with: endDate.previousMonth()) {
                    showMonth = nextMonth
                    return false
                } else {
                    showMonth = nextMonth
                    sourceDatas.remove(at: 0)
                    sourceDatas.append(getAllDatesData(by: showMonth.nextMonth()))
                    return true
                }
            }
        } else {
            if !showMonth.isMonthEqual(with: endDate) {
                showMonth = endDate
            }
            return false
        }
    }
    
    func datesMoveBackward() -> Bool {
        if totalMonthCount > 2 {
            if showMonth.isMonthEqual(with: endDate) {
                showMonth = previousMonth
                return true
            } else {
                if showMonth.isMonthEqual(with: startDate) {
                    return false
                } else if showMonth.isMonthEqual(with: startDate.nextMonth()) {
                    showMonth = previousMonth
                    return false
                } else {
                    showMonth = previousMonth
                    sourceDatas.removeLast()
                    sourceDatas.insert(getAllDatesData(by: showMonth.previousMonth()), at: 0)
                    return true
                }
            }
        } else {
            if !showMonth.isMonthEqual(with: startDate)  {
                showMonth = startDate
            }
            return false
        }
    }
    
    var monthString: String {
        let month = Calendar.current.component(Calendar.Component.month, from: showMonth)
        return "\(month)"
    }
    var yearString: String {
        let year = Calendar.current.component(Calendar.Component.year, from: showMonth)
        return "\(year)"
    }
}

class MonthDatasModel {
    var dateArray: Array<DateModel>
    var showMonth: Date
    
    init(dateArray: Array<DateModel>,
         showMonth: Date) {
        self.dateArray = dateArray
        self.showMonth = showMonth
    }
}

class DateModel {
    let date: Date
    let isOutRange: Bool
    var isSelected: Bool
    
    init(date: Date, isOutRange: Bool = false, isSelected: Bool = false) {
        self.date = date
        self.isOutRange = isOutRange
        self.isSelected = isSelected
    }
    
    var dateIndexString: String {
        return "\(Calendar.current.component(.day, from: date))"
    }

    var isToday: Bool {
        return Calendar.current.isDateInToday(date)
    }
}

enum WeekDay {
    case sun
    case mon
    case tue
    case wed
    case thu
    case fri
    case sta
    
    var desc: String {
        switch self {
        case .sun:
            return "日"
        case .mon:
            return "一"
        case .tue:
            return "二"
        case .wed:
            return "三"
        case .thu:
            return "四"
        case .fri:
            return "五"
        case .sta:
            return "六"
        }
    }
    
    static var allItem: [WeekDay] {
        return [.sun, .mon, .tue, .wed, .thu, .fri, .sta]
    }
}
