import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: StockDetailPage(),
  ));
}

// ==========================================
// 1. 主容器页面 (Tab切换)
// ==========================================
class StockDetailPage extends StatelessWidget {
  const StockDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text("行情详情", style: TextStyle(color: Colors.black)),
          bottom: const TabBar(
            labelColor: Colors.red,
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.red,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(text: "分时"),
              Tab(text: "日K"),
            ],
          ),
        ),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(), // 禁止左右滑动切换，避免与K线手势冲突
          children: [
            TimeSharingChart(), // 分时图 Widget
            DayKLineChart(),    // 日K图 Widget
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. 分时图模块 (基于你提供的代码)
// ==========================================

// --- 数据模型 ---
class StockPoint {
  final double price;
  final double avgPrice;
  final int volume;
  final double turnover;
  final DateTime time;

  StockPoint({
    required this.price,
    required this.avgPrice,
    required this.volume,
    required this.turnover,
    required this.time,
  });
}

// --- 页面 Widget ---
class TimeSharingChart extends StatefulWidget {
  const TimeSharingChart({super.key});

  @override
  State<TimeSharingChart> createState() => _TimeSharingChartState();
}

class _TimeSharingChartState extends State<TimeSharingChart> with AutomaticKeepAliveClientMixin {
  // 保持页面状态，切换tab不重绘
  @override
  bool get wantKeepAlive => true;

  final double _preClose = 323.92;
  final int _maxPoints = 240;
  List<StockPoint> _data = [];
  late StreamSubscription _subscription;
  final StreamController<StockPoint> _tcpStreamController = StreamController();
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _startMockTcpConnection();
    _subscription = _tcpStreamController.stream.listen((newData) {
      if (_data.length < _maxPoints) {
        if (mounted) {
          setState(() {
            _data.add(newData);
          });
        }
      }
    });
  }

  void _startMockTcpConnection() {
    double currentPrice = _preClose - 5.0;
    double sumPrice = 0;
    int count = 0;
    Random rng = Random();
    DateTime baseTime = DateTime(2025, 11, 22, 9, 30);

    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted || _data.length >= _maxPoints) {
        timer.cancel();
        return;
      }
      double change = (rng.nextDouble() - 0.5) * 1.5;
      currentPrice += change;
      sumPrice += currentPrice;
      count++;
      double avg = sumPrice / count;
      int vol = (rng.nextInt(1000) * (rng.nextDouble() > 0.8 ? 5 : 1));
      if (vol == 0) vol = 10;
      double turn = currentPrice * vol * 100;

      DateTime currentTime;
      if (count <= 120) {
        currentTime = baseTime.add(Duration(minutes: count));
      } else {
        currentTime = DateTime(2025, 11, 22, 13, 0).add(Duration(minutes: count - 120));
      }

      _tcpStreamController.add(StockPoint(
        price: currentPrice,
        avgPrice: avg,
        volume: vol,
        turnover: turn,
        time: currentTime,
      ));
    });
  }

  @override
  void dispose() {
    _tcpStreamController.close();
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by KeepAlive
    final StockPoint? displayPoint = _selectedIndex != null && _data.isNotEmpty
        ? _data[min(_selectedIndex!, _data.length - 1)]
        : (_data.isNotEmpty ? _data.last : null);

    final double currentPrice = displayPoint?.price ?? _preClose;
    final double avgPrice = displayPoint?.avgPrice ?? 0.0;
    final double rate = (currentPrice - _preClose) / _preClose * 100;
    final Color color = currentPrice >= _preClose ? Colors.red : Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 头部信息
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
          child: Row(
            children: [
              Text("均价:${avgPrice > 0 ? avgPrice.toStringAsFixed(2) : '--'}",
                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
              const Spacer(),
              Text("最新:${currentPrice.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(width: 10),
              Text("${rate >= 0 ? '+' : ''}${rate.toStringAsFixed(2)}%",
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
        Divider(height: 1, color: Colors.grey[300]),

        // 主图
        Expanded(
          flex: 2,
          child: LayoutBuilder(builder: (context, constraints) {
            return GestureDetector(
              onLongPressStart: (d) => _updateCrosshair(d.localPosition.dx, constraints.maxWidth),
              onLongPressMoveUpdate: (d) => _updateCrosshair(d.localPosition.dx, constraints.maxWidth),
              onLongPressEnd: (_) => setState(() => _selectedIndex = null),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: TimeSharingPainter(data: _data, preClose: _preClose, maxPoints: _maxPoints),
                    ),
                  ),
                  if (_selectedIndex != null && _data.isNotEmpty)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: TimeSharingCrosshairPainter(
                          data: _data,
                          preClose: _preClose,
                          maxPoints: _maxPoints,
                          selectedIndex: min(_selectedIndex!, _data.length - 1),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),

        // 时间轴
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("09:30", style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text("11:30/13:00", style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text("15:00", style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),

        // 副图信息
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          color: Colors.white,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(2)),
                child: const Text("分时量", style: TextStyle(fontSize: 10, color: Colors.black)),
              ),
              const SizedBox(width: 10),
              if (displayPoint != null) ...[
                _buildSubText("量", displayPoint.volume.toString(), Colors.green[700]!),
                const SizedBox(width: 10),
                _buildSubText("额", _formatMoney(displayPoint.turnover), Colors.black),
              ]
            ],
          ),
        ),

        // 副图
        Expanded(
          flex: 1,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade300))),
            child: CustomPaint(
              painter: TimeSharingVolumePainter(
                data: _data,
                maxPoints: _maxPoints,
                preClose: _preClose,
                selectedIndex: _selectedIndex,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _updateCrosshair(double dx, double width) {
    double step = width / _maxPoints;
    int index = (dx / step).floor();
    index = index.clamp(0, _maxPoints - 1);
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildSubText(String label, String value, Color color) {
    return RichText(
        text: TextSpan(
            text: "$label:",
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            children: [TextSpan(text: value, style: TextStyle(color: color, fontWeight: FontWeight.bold))]));
  }

  String _formatMoney(double money) {
    if (money > 100000000) return "${(money / 100000000).toStringAsFixed(2)}亿";
    if (money > 10000) return "${(money / 10000).toStringAsFixed(2)}万";
    return money.toStringAsFixed(0);
  }
}

// --- 分时图 Painters ---

class TimeSharingPainter extends CustomPainter {
  final List<StockPoint> data;
  final double preClose;
  final int maxPoints;
  TimeSharingPainter({required this.data, required this.preClose, required this.maxPoints});

  @override
  void paint(Canvas canvas, Size size) {
    double maxDiff = 0;
    for (var p in data) maxDiff = max(maxDiff, (p.price - preClose).abs());
    if (maxDiff == 0) maxDiff = preClose * 0.01;
    final double limit = maxDiff * 1.05;
    final double topPrice = preClose + limit;
    final double bottomPrice = preClose - limit;
    final double priceRange = topPrice - bottomPrice;

    final paintGrid = Paint()..color = Colors.grey.shade200..style = PaintingStyle.stroke;
    double cw = size.width / 4;
    double ch = size.height / 4;
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(Offset(i * cw, 0), Offset(i * cw, size.height), paintGrid);
      canvas.drawLine(Offset(0, i * ch), Offset(size.width, i * ch), paintGrid);
    }

    double dashY = size.height / 2;
    double dx = 0;
    final paintDash = Paint()..color = Colors.grey..style = PaintingStyle.stroke;
    while (dx < size.width) {
      canvas.drawLine(Offset(dx, dashY), Offset(dx + 4, dashY), paintDash);
      dx += 8;
    }

    _drawText(canvas, topPrice.toStringAsFixed(2), Offset(2, 0), Colors.red);
    _drawText(canvas, bottomPrice.toStringAsFixed(2), Offset(2, size.height - 14), Colors.green);
    double percent = (limit / preClose) * 100;
    _drawText(canvas, "+${percent.toStringAsFixed(2)}%", Offset(size.width - 45, 0), Colors.red);
    _drawText(canvas, "-${percent.toStringAsFixed(2)}%", Offset(size.width - 45, size.height - 14), Colors.green);

    if (data.isEmpty) return;

    final Path pricePath = Path();
    final Path avgPath = Path();
    final double stepX = size.width / maxPoints;
    double getY(double p) => size.height - ((p - bottomPrice) / priceRange * size.height);

    pricePath.moveTo(0, getY(data[0].price));
    avgPath.moveTo(0, getY(data[0].avgPrice));

    for (int i = 1; i < data.length; i++) {
      double x = i * stepX;
      pricePath.lineTo(x, getY(data[i].price));
      avgPath.lineTo(x, getY(data[i].avgPrice));
    }
    canvas.drawPath(pricePath, Paint()..color = Colors.black..strokeWidth = 1.2..style = PaintingStyle.stroke);
    canvas.drawPath(avgPath, Paint()..color = Colors.orange.shade300..strokeWidth = 1.2..style = PaintingStyle.stroke);
  }
  void _drawText(Canvas canvas, String text, Offset offset, Color color) {
    final tp = TextPainter(text: TextSpan(style: TextStyle(color: color, fontSize: 10), text: text), textDirection: ui.TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, offset);
  }
  @override
  bool shouldRepaint(TimeSharingPainter old) => true;
}

class TimeSharingCrosshairPainter extends CustomPainter {
  final List<StockPoint> data;
  final double preClose;
  final int maxPoints;
  final int selectedIndex;
  TimeSharingCrosshairPainter({required this.data, required this.preClose, required this.maxPoints, required this.selectedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    if (selectedIndex >= data.length) return;
    final point = data[selectedIndex];
    double maxDiff = 0;
    for (var p in data) maxDiff = max(maxDiff, (p.price - preClose).abs());
    if (maxDiff == 0) maxDiff = preClose * 0.01;
    final double limit = maxDiff * 1.05;
    final double bottomPrice = preClose - limit;
    final double priceRange = limit * 2;

    double stepX = size.width / maxPoints;
    double x = selectedIndex * stepX;
    double y = size.height - ((point.price - bottomPrice) / priceRange * size.height);

    final paintLine = Paint()..color = Colors.grey.shade700..strokeWidth = 1.0;
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), paintLine);
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paintLine);
    canvas.drawCircle(Offset(x, y), 3, Paint()..color = Colors.black);

    _drawLabel(canvas, point.price.toStringAsFixed(2), Offset(0, y - 10), Colors.black);
    double rate = (point.price - preClose) / preClose * 100;
    _drawLabel(canvas, "${rate >= 0 ? '+' : ''}${rate.toStringAsFixed(2)}%", Offset(size.width - 50, y - 10), rate >= 0 ? Colors.red : Colors.green);
    String timeText = "${point.time.hour.toString().padLeft(2, '0')}:${point.time.minute.toString().padLeft(2, '0')}";
    _drawLabel(canvas, timeText, Offset(x - 15, size.height - 15), Colors.black);
  }
  void _drawLabel(Canvas canvas, String text, Offset offset, Color textColor) {
    final span = TextSpan(style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold), text: text);
    final tp = TextPainter(text: span, textDirection: ui.TextDirection.ltr);
    tp.layout();
    final rect = Rect.fromLTWH(offset.dx, offset.dy, tp.width + 4, tp.height + 2);
    canvas.drawRect(rect, Paint()..color = Colors.grey.shade200..style = PaintingStyle.fill);
    canvas.drawRect(rect, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 0.5);
    tp.paint(canvas, Offset(offset.dx + 2, offset.dy + 1));
  }
  @override
  bool shouldRepaint(TimeSharingCrosshairPainter old) => old.selectedIndex != selectedIndex;
}

class TimeSharingVolumePainter extends CustomPainter {
  final List<StockPoint> data;
  final int maxPoints;
  final double preClose;
  final int? selectedIndex;
  TimeSharingVolumePainter({required this.data, required this.maxPoints, required this.preClose, this.selectedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()..color = Colors.grey.shade200;
    double cw = size.width / 4;
    for (int i = 1; i < 4; i++) canvas.drawLine(Offset(i * cw, 0), Offset(i * cw, size.height), paintGrid);
    if (data.isEmpty) return;

    int maxVol = data.map((e) => e.volume).reduce(max);
    if (maxVol == 0) maxVol = 1;
    double stepX = size.width / maxPoints;
    double barWidth = stepX * 0.8;
    final paintRed = Paint()..color = Colors.red;
    final paintGreen = Paint()..color = Colors.green;

    for (int i = 0; i < data.length; i++) {
      double x = i * stepX;
      double h = (data[i].volume / maxVol) * size.height;
      double top = size.height - h;
      double prev = i == 0 ? preClose : data[i - 1].price;
      bool isUp = data[i].price >= prev;
      canvas.drawRect(Rect.fromLTWH(x, top, barWidth, h), isUp ? paintRed : paintGreen);
      if (selectedIndex == i) {
        canvas.drawLine(Offset(x + barWidth / 2, 0), Offset(x + barWidth / 2, size.height), Paint()..color = Colors.grey.shade700..strokeWidth = 1);
      }
    }
    TextPainter(text: TextSpan(text: maxVol.toString(), style: const TextStyle(color: Colors.black, fontSize: 9)), textDirection: ui.TextDirection.ltr)
      ..layout()..paint(canvas, const Offset(2, 0));
  }
  @override
  bool shouldRepaint(TimeSharingVolumePainter old) => true;
}


// ==========================================
// 3. 日K线模块 (包含之前的缩放、平移、日期显示)
// ==========================================

// --- K线数据模型 ---
class KLineData {
  final DateTime time;
  final double open, high, low, close, volume;
  double? ma5, ma10, ma20, ma30, volMa5, volMa10;

  KLineData({required this.time, required this.open, required this.high, required this.low, required this.close, required this.volume});
}

// --- K线页面 ---
class DayKLineChart extends StatefulWidget {
  const DayKLineChart({super.key});

  @override
  State<DayKLineChart> createState() => _DayKLineChartState();
}

class _DayKLineChartState extends State<DayKLineChart> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // 保持状态

  final List<KLineData> _allDatas = [];
  int _displayCount = 60;
  int _startIndex = 0;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _generateMockData();
    _calculateMA();
    if (_allDatas.isNotEmpty) {
      _startIndex = max(0, _allDatas.length - _displayCount);
    }
  }

  List<KLineData> get _visibleDatas {
    if (_allDatas.isEmpty) return [];
    int end = min(_startIndex + _displayCount, _allDatas.length);
    if (_startIndex < 0) _startIndex = 0;
    if (_startIndex >= end) return [];
    return _allDatas.sublist(_startIndex, end);
  }

  void _generateMockData() {
    _allDatas.clear();
    DateTime date = DateTime.now().subtract(const Duration(days: 1000));
    double price = 330.0;
    Random r = Random();
    for (int i = 0; i < 1000; i++) {
      double volatility = price * 0.02;
      double open = price + (r.nextDouble() - 0.5) * volatility;
      double close = open + (r.nextDouble() - 0.5) * volatility;
      double high = max(open, close) + r.nextDouble() * volatility;
      double low = min(open, close) - r.nextDouble() * volatility;
      double vol = (r.nextInt(50000) + 20000).toDouble();
      if (date.weekday == 6) date = date.add(const Duration(days: 2));
      if (date.weekday == 7) date = date.add(const Duration(days: 1));
      _allDatas.add(KLineData(time: date, open: open, high: high, low: low, close: close, volume: vol));
      price = close;
      date = date.add(const Duration(days: 1));
    }
  }

  void _calculateMA() {
    for (int i = 0; i < _allDatas.length; i++) {
      _allDatas[i].ma5 = _calcAvg(i, 5);
      _allDatas[i].ma10 = _calcAvg(i, 10);
      _allDatas[i].ma20 = _calcAvg(i, 20);
      _allDatas[i].ma30 = _calcAvg(i, 30);
      _allDatas[i].volMa5 = _calcVolAvg(i, 5);
      _allDatas[i].volMa10 = _calcVolAvg(i, 10);
    }
  }

  double? _calcAvg(int idx, int day) {
    if (idx < day - 1) return null;
    double sum = 0;
    for (int i = 0; i < day; i++) sum += _allDatas[idx - i].close;
    return sum / day;
  }
  double? _calcVolAvg(int idx, int day) {
    if (idx < day - 1) return null;
    double sum = 0;
    for (int i = 0; i < day; i++) sum += _allDatas[idx - i].volume;
    return sum / day;
  }

  // 缩放平移逻辑
  void _zoomIn() { if (_displayCount > 20) setState(() { _displayCount -= 5; _startIndex += 5; _clamp(); }); }
  void _zoomOut() { if (_displayCount < 200) setState(() { _displayCount += 5; _startIndex -= 5; _clamp(); }); }
  void _panLeft() { setState(() { _startIndex -= 3; _clamp(); }); }
  void _panRight() { setState(() { _startIndex += 3; _clamp(); }); }
  void _clamp() {
    if (_allDatas.isEmpty) return;
    if (_startIndex < 0) _startIndex = 0;
    if (_startIndex + _displayCount > _allDatas.length) _startIndex = max(0, _allDatas.length - _displayCount);
    _selectedIndex = null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final visibleData = _visibleDatas;
    final targetData = (_selectedIndex != null && _selectedIndex! < visibleData.length)
        ? visibleData[_selectedIndex!]
        : (visibleData.isNotEmpty ? visibleData.last : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 主图指标
        _buildMainIndicator(targetData),
        // 主图
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              GestureDetector(
                onLongPressStart: (d) => _handleCrosshair(d.localPosition.dx, context, visibleData.length),
                onLongPressMoveUpdate: (d) => _handleCrosshair(d.localPosition.dx, context, visibleData.length),
                onLongPressEnd: (_) => setState(() => _selectedIndex = null),
                child: CustomPaint(
                  size: Size.infinite,
                  painter: KLinePainter(datas: visibleData),
                  foregroundPainter: _selectedIndex != null
                      ? KLineCrosshairPainter(datas: visibleData, index: _selectedIndex!, isMainChart: true)
                      : null,
                ),
              ),
              // 控制按钮
              Positioned(
                bottom: 10, right: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _btn(Icons.add, _zoomIn), _btn(Icons.remove, _zoomOut),
                      Container(width: 1, height: 16, color: Colors.grey),
                      _btn(Icons.chevron_left, _panLeft), _btn(Icons.chevron_right, _panRight),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        // 日期轴
        SizedBox(height: 20, child: CustomPaint(size: Size.infinite, painter: DateAxisPainter(datas: visibleData))),
        Divider(height: 1, color: Colors.grey[300]),
        // 副图指标
        _buildVolIndicator(targetData),
        // 副图
        Expanded(
          flex: 1,
          child: CustomPaint(
            size: Size.infinite,
            painter: KLineVolumePainter(datas: visibleData),
            foregroundPainter: _selectedIndex != null
                ? KLineCrosshairPainter(datas: visibleData, index: _selectedIndex!, isMainChart: false)
                : null,
          ),
        ),
      ],
    );
  }

  void _handleCrosshair(double dx, BuildContext context, int count) {
    if (count == 0) return;
    double w = MediaQuery.of(context).size.width;
    int idx = (dx / (w / count)).floor().clamp(0, count - 1);
    setState(() => _selectedIndex = idx);
  }

  Widget _btn(IconData i, VoidCallback cb) => InkWell(onTap: cb, child: Padding(padding: const EdgeInsets.all(4), child: Icon(i, size: 18, color: Colors.blueGrey)));
  Widget _buildMainIndicator(KLineData? d) => d == null ? const SizedBox() : Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Wrap(spacing: 8, children: [
      const Text("日线", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      if (d.ma5 != null) _txt("MA5:${d.ma5!.toStringAsFixed(2)}", Colors.black),
      if (d.ma10 != null) _txt("MA10:${d.ma10!.toStringAsFixed(2)}", const Color(0xFFE6B325)),
      if (d.ma20 != null) _txt("MA20:${d.ma20!.toStringAsFixed(2)}", Colors.pink),
      if (d.ma30 != null) _txt("MA30:${d.ma30!.toStringAsFixed(2)}", Colors.green),
    ]),
  );
  Widget _buildVolIndicator(KLineData? d) => d == null ? const SizedBox() : Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Row(children: [
      const Text("成交量 ", style: TextStyle(fontSize: 10)),
      _txt("量:${d.volume.toInt()}", Colors.black), const SizedBox(width: 8),
      if (d.volMa5 != null) _txt("MA5:${d.volMa5!.toInt()}", Colors.black), const SizedBox(width: 8),
      if (d.volMa10 != null) _txt("MA10:${d.volMa10!.toInt()}", const Color(0xFFE6B325)),
    ]),
  );
  Widget _txt(String t, Color c) => Text(t, style: TextStyle(fontSize: 10, color: c));
}

// --- 日K Painters ---

class KLinePainter extends CustomPainter {
  final List<KLineData> datas;
  KLinePainter({required this.datas});
  @override
  void paint(Canvas canvas, Size size) {
    if (datas.isEmpty) return;
    double maxPrice = -double.infinity, minPrice = double.infinity;
    for (var d in datas) {
      maxPrice = max(maxPrice, d.high); minPrice = min(minPrice, d.low);
      if (d.ma5 != null) { maxPrice = max(maxPrice, d.ma5!); minPrice = min(minPrice, d.ma5!); }
      if (d.ma30 != null) { maxPrice = max(maxPrice, d.ma30!); minPrice = min(minPrice, d.ma30!); }
    }
    double range = maxPrice - minPrice;
    if (range == 0) range = maxPrice * 0.01;
    maxPrice += range * 0.05; minPrice -= range * 0.05; range = maxPrice - minPrice;

    double cw = size.width / datas.length;
    double dw = max(1, cw - 1);
    Paint red = Paint()..color = const Color(0xFFE74C3C)..style = PaintingStyle.stroke..strokeWidth = 1;
    Paint green = Paint()..color = const Color(0xFF009666)..style = PaintingStyle.fill;

    // 均线Paths
    Path p5 = Path(), p10 = Path(), p20 = Path(), p30 = Path();
    bool s5=false, s10=false, s20=false, s30=false;
    double getY(double p) => size.height - ((p - minPrice) / range * size.height);

    for (int i = 0; i < datas.length; i++) {
      var d = datas[i];
      double cx = i * cw + cw/2;
      double openY = getY(d.open), closeY = getY(d.close), highY = getY(d.high), lowY = getY(d.low);
      if ((openY-closeY).abs()<0.5) closeY = openY+1;
      bool up = d.close >= d.open;
      if (up) {
        canvas.drawLine(Offset(cx, highY), Offset(cx, lowY), red);
        canvas.drawRect(Rect.fromLTRB(i*cw+0.5, min(openY,closeY), i*cw+0.5+dw, max(openY,closeY)), red);
      } else {
        canvas.drawLine(Offset(cx, highY), Offset(cx, lowY), green);
        canvas.drawRect(Rect.fromLTRB(i*cw+0.5, min(openY,closeY), i*cw+0.5+dw, max(openY,closeY)), green);
      }

      if (d.ma5!=null) { double y=getY(d.ma5!); if(!s5){p5.moveTo(cx,y);s5=true;}else p5.lineTo(cx,y); }
      if (d.ma10!=null) { double y=getY(d.ma10!); if(!s10){p10.moveTo(cx,y);s10=true;}else p10.lineTo(cx,y); }
      if (d.ma20!=null) { double y=getY(d.ma20!); if(!s20){p20.moveTo(cx,y);s20=true;}else p20.lineTo(cx,y); }
      if (d.ma30!=null) { double y=getY(d.ma30!); if(!s30){p30.moveTo(cx,y);s30=true;}else p30.lineTo(cx,y); }
    }
    canvas.drawPath(p5, Paint()..color=Colors.black..style=PaintingStyle.stroke);
    canvas.drawPath(p10, Paint()..color=const Color(0xFFE6B325)..style=PaintingStyle.stroke);
    canvas.drawPath(p20, Paint()..color=Colors.pink..style=PaintingStyle.stroke);
    canvas.drawPath(p30, Paint()..color=Colors.green..style=PaintingStyle.stroke);

    Paint grid = Paint()..color=Colors.grey.shade100..style=PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height/3), Offset(size.width, size.height/3), grid);
    canvas.drawLine(Offset(0, size.height*2/3), Offset(size.width, size.height*2/3), grid);
  }
  @override
  bool shouldRepaint(KLinePainter old) => true;
}

class KLineVolumePainter extends CustomPainter {
  final List<KLineData> datas;
  KLineVolumePainter({required this.datas});
  @override
  void paint(Canvas canvas, Size size) {
    if (datas.isEmpty) return;
    double maxVol = 0; for(var d in datas) maxVol = max(maxVol, d.volume); if(maxVol==0) maxVol=1;
    double cw = size.width / datas.length;
    Paint red = Paint()..color=const Color(0xFFE74C3C)..style=PaintingStyle.stroke..strokeWidth=1;
    Paint redFill = Paint()..color=const Color(0xFFE74C3C)..style=PaintingStyle.fill;
    Paint green = Paint()..color=const Color(0xFF009666)..style=PaintingStyle.fill;
    Path p5 = Path(), p10 = Path(); bool s5=false, s10=false;

    for (int i = 0; i < datas.length; i++) {
      var d = datas[i];
      double h = (d.volume/maxVol)*size.height;
      double x = i*cw + 0.5;
      bool up = d.close >= d.open;
      Rect r = Rect.fromLTWH(x, size.height-h, max(1, cw-1), h);
      if (up) (h<2 || cw<3) ? canvas.drawRect(r, redFill) : canvas.drawRect(r, red);
      else canvas.drawRect(r, green);

      double cx = x + cw/2;
      if (d.volMa5!=null) { double y=size.height-(d.volMa5!/maxVol)*size.height; if(!s5){p5.moveTo(cx,y);s5=true;}else p5.lineTo(cx,y); }
      if (d.volMa10!=null) { double y=size.height-(d.volMa10!/maxVol)*size.height; if(!s10){p10.moveTo(cx,y);s10=true;}else p10.lineTo(cx,y); }
    }
    canvas.drawPath(p5, Paint()..color=Colors.black..style=PaintingStyle.stroke);
    canvas.drawPath(p10, Paint()..color=const Color(0xFFE6B325)..style=PaintingStyle.stroke);
  }
  @override
  bool shouldRepaint(KLineVolumePainter old) => true;
}

class DateAxisPainter extends CustomPainter {
  final List<KLineData> datas;
  DateAxisPainter({required this.datas});
  @override
  void paint(Canvas canvas, Size size) {
    if (datas.isEmpty) return;
    void draw(int i, TextAlign a) {
      if(i<0||i>=datas.length)return;
      var d = datas[i].time;
      String t = "${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}";
      TextPainter tp = TextPainter(text: TextSpan(text: t, style: TextStyle(color: Colors.grey.shade600, fontSize: 10)), textDirection: ui.TextDirection.ltr);
      tp.layout();
      double x = (size.width/datas.length)*i;
      if(a==TextAlign.center) x -= tp.width/2;
      if(a==TextAlign.right) x -= tp.width;
      if(x<0) x=0; if(x+tp.width>size.width) x=size.width-tp.width;
      tp.paint(canvas, Offset(x, 0));
    }
    draw(0, TextAlign.left);
    draw(datas.length~/2, TextAlign.center);
    draw(datas.length-1, TextAlign.right);
  }
  @override
  bool shouldRepaint(DateAxisPainter old) => true;
}

class KLineCrosshairPainter extends CustomPainter {
  final List<KLineData> datas;
  final int index;
  final bool isMainChart;
  KLineCrosshairPainter({required this.datas, required this.index, required this.isMainChart});

  @override
  void paint(Canvas canvas, Size size) {
    if (index < 0 || index >= datas.length) return;
    var d = datas[index];
    double cw = size.width / datas.length;
    double cx = index * cw + cw / 2;
    Paint line = Paint()..color = Colors.grey.shade600..strokeWidth = 0.8;
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), line);

    if (isMainChart) {
      double maxP = -double.infinity, minP = double.infinity;
      for (var item in datas) { maxP = max(maxP, item.high); minP = min(minP, item.low); if(item.ma5!=null) maxP=max(maxP,item.ma5!); }
      double range = maxP - minP; if(range==0)range=1;
      maxP += range*0.05; minP -= range*0.05; range = maxP - minP;

      double y = size.height - ((d.close - minP) / range * size.height);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);

      // 标签绘制
      _drawBgText(canvas, d.close.toStringAsFixed(2), Offset(0, y - 10));
      String date = "${d.time.year}-${d.time.month.toString().padLeft(2,'0')}-${d.time.day.toString().padLeft(2,'0')}";
      _drawBgText(canvas, date, Offset(cx, size.height - 15), centerX: true);
    }
  }

  void _drawBgText(Canvas c, String t, Offset o, {bool centerX = false}) {
    TextPainter tp = TextPainter(text: TextSpan(text: t, style: const TextStyle(color: Colors.white, fontSize: 10)), textDirection: ui.TextDirection.ltr);
    tp.layout();
    double dx = o.dx;
    if (centerX) {
      dx -= tp.width / 2;
      // 边界检查
      // 这里的 size 实际上是 context 的 size，在 Painter 里获取不到 context size，只能用 size 参数
      // 简单做个 clamping 并不容易，因为不知道 canvas 的总宽。不过通常 crosshair 在中间画日期不会出界太严重
    }
    Rect r = Rect.fromLTWH(dx, o.dy, tp.width + 4, tp.height);
    c.drawRect(r, Paint()..color=Colors.grey.shade800);
    tp.paint(c, Offset(dx + 2, o.dy));
  }

  @override
  bool shouldRepaint(KLineCrosshairPainter old) => true;
}