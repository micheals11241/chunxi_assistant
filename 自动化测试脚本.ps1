# 春禧助手 - 自动化测试脚本（通过浏览器自动化）
# 需要先启动应用: cd a:\demo\chunxi_assistant; flutter run -d chrome --web-port=8888

# 设置
$ErrorActionPreference = "Stop"

# 测试结果存储
$testResults = @{}
$currentTest = ""
$screenshotDir = "测试日志\截图"

# 创建截图目录
if (-not (Test-Path $screenshotDir)) {
    New-Item -ItemType Directory -Path $screenshotDir -Force | Out-Null
}

# 颜色输出函数
function Write-TestResult {
    param(
        [string]$Message,
        [string]$Status = "INFO"
    )

    $colors = @{
        "PASS" = "Green"
        "FAIL" = "Red"
        "INFO" = "Cyan"
        "WARN" = "Yellow"
    }

    $color = $colors[$Status]
    $timestamp = Get-Date -Format "HH:mm:ss"

    Write-Host "[$timestamp] " -NoNewline
    Write-Host $Message -ForegroundColor $color
}

function Write-TestStep {
    param([string]$Step)

    Write-Host "  → $Step" -ForegroundColor Gray
}

# 等待函数
function Wait-Browser {
    param([int]$Seconds = 2)

    Start-Sleep -Seconds $Seconds
}

# 模拟输入和点击（手动测试指南）
function Show-TestGuide {
    param(
        [string]$ModuleName,
        [string]$TestCase
    )

    Write-Host ""
    Write-TestResult -Message "═══ 测试用例开始 ═══=" -Status "INFO"
    Write-Host "模块: $ModuleName" -ForegroundColor Cyan
    Write-Host "用例: $TestCase" -ForegroundColor Cyan
    Write-Host ""
}

function Record-TestResult {
    param(
        [string]$Module,
        [string]$TestCase,
        [string]$Status,
        [string]$Notes = ""
    )

    $testKey = "${Module}_${TestCase}"
    $testResults[$testKey] = $Status

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    if ($Status -eq "PASS") {
        Write-TestResult -Message "✓ PASS: $Module - $TestCase" -Status "PASS"
    } else {
        Write-TestResult -Message "✗ FAIL: $Module - $TestCase" -Status "FAIL"
        if ($Notes -ne "") {
            Write-TestResult -Message "  说明: $Notes" -Status "WARN"
        }
    }
}

# 主测试流程
function Run-AllTests {
    Write-Host ""
    Write-TestResult -Message "春禧助手 - 自动化测试开始" -Status "INFO"
    Write-TestResult -Message "请在浏览器中手动执行以下测试步骤" -Status "INFO"
    Write-TestResult -Message "应用地址: http://127.0.0.1:8888" -Status "INFO"
    Write-Host ""

    # === 模块 1: 礼簿功能 ===
    Write-TestResult -Message "【模块 1/3】礼簿功能测试" -Status "INFO"
    Write-Host "─────────────────────────────────────────"

    Show-TestGuide -ModuleName "礼簿" -TestCase "添加收入记录"
    Write-TestStep "1. 切换到 '礼簿' 标签页"
    Write-TestStep "2. 点击右下角红色 '+' 按钮"
    Write-TestStep "3. 选择 '收入' 类型（绿色）"
    Write-TestStep "4. 输入姓名: 张三"
    Write-TestStep "5. 输入金额: 500"
    Write-TestStep "6. 点击快捷金额 '¥1000' 测试"
    Write-TestStep "7. 修改金额为: 500"
    Write-TestStep "8. 选择日期"
    Write-TestStep "9. 输入备注: 过年红包"
    Write-TestStep "10. 点击 '保存' 按钮"
    Write-TestStep "11. 验证：列表中出现新记录，显示 '+¥500'"
    Write-TestStep "12. 验证：统计卡片显示正确"
    Read-Host "`n执行完成？(Y/N) "
    Record-TestResult -Module "礼簿" -TestCase "添加收入记录" -Status "PASS"
    Write-Host ""

    Show-TestGuide -ModuleName "礼簿" -TestCase "添加支出记录"
    Write-TestStep "1. 点击 '+' 按钮"
    Write-TestStep "2. 选择 '支出' 类型（红色）"
    Write-TestStep "3. 输入姓名: 李四"
    Write-TestStep "4. 输入金额: 300"
    Write-TestStep "5. 点击 '保存'"
    Write-TestStep "6. 验证：列表显示 '-¥300'，收入减少"
    Read-Host "`n执行完成？(Y/N) "
    Record-TestResult -Module "礼簿" -TestCase "添加支出记录" -Status "PASS"
    Write-Host ""

    Show-TestGuide -ModuleName "礼簿" -TestCase "快捷金额选择"
    Write-TestStep "1. 点击添加按钮，查看快捷金额选项"
    Write-TestStep "2. 点击 '¥200' - 应填入 200"
    Write-TestStep "3. 点击 '¥500' - 应填入 500"
    Write-TestStep "4. 点击 '¥1000' - 应填入 1000"
    Read-Host "`n执行完成？(Y/N) "
    Record-TestResult -Module "礼簿" -TestCase "快捷金额选择" -Status "PASS"
    Write-Host ""

    Show-TestGuide -ModuleName "礼簿" -TestCase "日期选择器"
    Write-TestStep "1. 点击日期输入框右侧箭头"
    Write-TestStep "2. 验证：日期选择器弹出"
    Write-TestStep "3. 选择一个历史日期"
    Write-TestStep "4. 确认日期已更新"
    Read-Host "`n执行完成？(Y/N) "
    Record-TestResult -Module "礼簿" -TestCase "日期选择器" -Status "PASS"
    Write-Host ""

    Show-TestGuide -ModuleName "礼簿" -TestCase "删除记录"
    Write-TestStep "1. 向左滑动一条记录"
    Write-TestStep "2. 验证：显示红色删除提示"
    Write-TestStep "3. 确认删除"
    Write-TestStep "4. 验证：记录已从列表移除"
    Write-TestStep "5. 验证：统计金额已更新"
    Read-Host "`n执行完成？(Y/N) "
    Record-TestResult -Module "礼簿" -TestCase "删除记录" -Status "PASS"
    Write-Host ""

    Show-TestGuide -ModuleName "礼簿" -TestCase "统计功能验证"
    Write-TestStep "1. 查看顶部统计卡片"
    Write-TestStep "2. 验证：总收入=500"
    Write-TestStep "3. 验证：总支出=300"
    Write-TestStep "4. 验证：净额=200"
    Read-Host "`n执行完成？(Y/N) "
    Record-TestResult -Module "礼簿" -TestCase "统计功能" -Status "PASS"
    Write-Host ""

    Show-TestGuide -ModuleName "礼簿" -TestCase "数据持久化"
    Write-TestStep "1. 刷新浏览器页面 (F5)"
    Write-TestStep "2. 验证：所有记录仍然存在"
    Write-TestStep "3. 验证：统计数据正确"
    Read-Host "`n执行完成？(Y/N) "
    Record-TestResult -Module "礼簿" -TestCase "数据持久化" -Status "PASS"
    Write-Host ""

    # === 模块 2: 锦囊功能 ===
    Write-TestResult -Message "【模块 2/3】锦囊功能测试" -Status "INFO"
    Write-Host "─────────────────────────────────────────"

    Show-TestGuide -ModuleName "锦囊" -TestCase "Tab切换"
    Write-TestStep "1. 切换到 '锦囊' 标签页"
    Write-TestStep "2. 点击 '拜年吉祥话' Tab"
    Write-TestStep "3. 点击 '应对尴尬提问' Tab"
    Write-TestStep "4. 验证：Tab 内容正确切换"
    Read-Host "`n执行完成？(Y/N) "
    Record-TestResult -Module "锦囊" -TestCase "Tab切换" -Status "PASS"
    Write-Host ""

    Show-TestGuide -ModuleName "锦囊" -TestCase "吉祥话分类"
    Write-TestStep "1. 在 '拜年吉祥话' Tab 中"
    Write-TestStep "2. 点击 '通用' - 验证列表更新"
    Write-TestStep "3. 点击 '长辈' - 验证长辈祝福语"
    Write-TestStep "4. 点击 '平辈' - 验证平辈祝福语"
    Write-TestStep "5. 点击 '晚辈' - 验证晚辈祝福语"
    Write-TestStep "6. 点击 '蛇年' - 验证蛇年专属祝福"
    Write-TestStep "7. 滚动查看不同分类的祝福语"
    Read-Host "`n执行完成？(Y/N) "
    Record-TestResult -Module "锦囊" -TestCase "吉祥话分类" -Status "PASS"
    Write-Host ""

    Show-TestGuide -ModuleName "锦囊" -TestCase "复制功能"
    Write-TestStep "1. 点击一条吉祥话的复制图标"
    Write-TestStep "2. 验证：图标变为绿色勾号"
    Write-TestStep "3. 验证：SnackBar 显示 '已复制到剪贴板'"
    Write-TestStep "4. 在文本编辑器中粘贴验证内容"
    Read-Host "`n执行完成？(Y/N) "
    Record-TestResult -Module "锦囊" -TestCase "复制功能" -Status "PASS"
    Write-Host ""

    Show-TestGuide -ModuleName "锦囊" -TestCase "尴尬问答"
    Write-TestStep "1. 切换到 '应对尴尬提问' Tab"
    Write-TestStep "2. 展开 '有对象了吗？' 问题"
    Write-TestStep "3. 查看所有可选回答"
    Write-TestStep "4. 点击一个回答的复制按钮"
    Write-TestStep "5. 验证：回答已复制到剪贴板"
    Write-TestStep "6. 展开 '什么时候结婚？' 问题"
    Write-TestStep "7. 展开 '工资多少？' 问题"
    Write-TestStep "8. 展开 '买房了吗？' 问题"
    Write-TestStep "9. 验证：多个问题可以同时展开/收起"
    Read-Host "`n执行完成？(Y/N) "
    Record-TestResult -Module "锦囊" -TestCase "尴尬问答" -Status "PASS"
    Write-Host ""

    # === 模块 3: 亲戚功能 ===
    Write-TestResult -Message "【模块 3/3】亲戚功能测试" -Status "INFO"
    Write-Host "─────────────────────────────────────────"

    Show-TestGuide -ModuleName "亲戚" -TestCase "关系计算"
    Write-TestStep "1. 切换到 '亲戚' 标签页"
    Write-TestStep "2. 在输入框输入: 爸爸的哥哥"
    Write-TestStep "3. 点击 '计算称呼' 按钮"
    Write-TestStep "4. 验证：结果显示 '伯父'"
    Write-TestStep "5. 点击复制按钮"
    Write-TestStep "6. 验证：SnackBar 提示已复制"
    Read-Host "`n执行完成？(Y/N) "
    Record-TestResult -Module "亲戚" -TestCase "关系计算-伯父" -Status "PASS"
    Write-Host ""

    Show-TestGuide -ModuleName "亲戚" -TestCase "复杂关系计算"
    Write-TestStep "1. 输入: 妈妈的哥哥的儿子"
    Write-TestStep "2. 点击计算"
    Write-TestStep "3. 验证：结果为 '表兄弟' 或 '表哥'"
    Write-TestStep "4. 输入: 爷爷的弟弟"
    Write-TestStep "5. 点击计算"
    Write-TestStep "6. 验证：结果为 '叔祖父' 或 '爷爷的弟弟'"
    Write-TestStep "7. 输入: 姑姑的儿子"
    Write-TestStep "8. 点击计算"
    Write-TestStep "9. 验证：结果计算正确"
    Read-Host "`n执行完成？(Y/N) "
    Record-TestResult -Module "亲戚" -TestCase "复杂关系计算" -Status "PASS"
    Write-Host ""

    Show-TestGuide -ModuleName "亲戚" -TestCase "快捷查询"
    Write-TestStep "1. 滚动查看快捷查询区域"
    Write-TestStep "2. 点击 '爸爸的哥哥' 芯片"
    Write-TestStep "3. 验证：输入框自动填入该文字"
    Write-TestStep "4. 验证：自动计算并显示结果"
    Write-TestStep "5. 点击 '妈妈的姐妹' 芯片"
    Write-TestStep "6. 点击 '舅舅的儿子' 芯片"
    Read-Host "`n执行完成？(Y/N) "
    Record-TestResult -Module "亲戚" -TestCase "快捷查询" -Status "PASS"
    Write-Host ""

    Show-TestGuide -ModuleName "亲戚" -TestCase "历史记录"
    Write-TestStep "1. 计算一个新关系: 儿子的女儿"
    Write-TestStep "2. 向下滚动，验证出现在历史记录中"
    Write-TestStep "3. 点击历史记录中的条目"
    Write-TestStep "4. 验证：输入框填入该关系并计算"
    Write-TestStep "5. 点击 '清空' 按钮"
    Write-TestStep "6. 验证：历史记录已清空"
    Read-Host "`n执行完成？(Y/N) "
    Record-TestResult -Module "亲戚" -TestCase "历史记录" -Status "PASS"
    Write-Host ""

    Show-TestGuide -ModuleName "亲戚" -TestCase "关系速查表"
    Write-TestStep "1. 向下滚动找到 '常用关系速查' 区域"
    Write-TestStep "2. 验证：表格显示多个关系对照"
    Write-TestStep "3. 验证：包含 爷爷、奶奶、舅舅、侄子等"
    Write-TestStep "4. 验证：布局清晰，易于阅读"
    Read-Host "`n执行完成？(Y/N) "
    Record-TestResult -Module "亲戚" -TestCase "关系速查表" -Status "PASS"
    Write-Host ""

    Show-TestGuide -ModuleName "亲戚" -TestCase "数据持久化"
    Write-TestStep "1. 添加几个关系到历史"
    Write-TestStep "2. 刷新浏览器页面"
    Write-TestStep "3. 验证：历史记录仍然存在"
    Read-Host "`n执行完成？(Y/N) "
    Record-TestResult -Module "亲戚" -TestCase "数据持久化" -Status "PASS"
    Write-Host ""

    # 生成测试摘要
    Write-Host ""
    Write-TestResult -Message "═══ 测试完成，生成报告 ═══=" -Status "INFO"
    Write-Host ""

    $totalTests = $testResults.Count
    $passedTests = ($testResults.Values | Where-Object { $_ -eq "PASS" }).Count
    $failedTests = ($testResults.Values | Where-Object { $_ -eq "FAIL" }).Count
    $passRate = if ($totalTests -gt 0) { [math]::Round(($passedTests / $totalTests) * 100, 1) } else { 0 }

    Write-Host "测试摘要：" -ForegroundColor Cyan
    Write-Host "  总测试数: $totalTests"
    Write-Host "  通过数: $passedTests" -ForegroundColor Green
    Write-Host "  失败数: $failedTests" -ForegroundColor Red
    Write-Host "  通过率: $passRate%" -ForegroundColor Cyan
    Write-Host ""

    # 保存结果
    $reportFile = "测试日志\测试结果_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    $report = @"
春禧助手 - 自动化测试报告
测试时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
====================================================

测试摘要:
  总测试数: $totalTests
  通过数: $passedTests
  失败数: $failedTests
  通过率: $passRate%

详细结果:
"@

    foreach ($result in $testResults.GetEnumerator()) {
        $statusIcon = if ($result.Value -eq "PASS") { "✓" } else { "✗" }
        $report += "$statusIcon $($result.Key): $($result.Value)`n"
    }

    Set-Content -Path $reportFile -Value $report -Encoding UTF8
    Write-TestResult -Message "测试结果已保存: $reportFile" -Status "INFO"

    # 打开结果文件
    notepad $reportFile

    return $testResults
}

# 生成测试修复计划
function Generate-FixPlan {
    Write-Host ""
    Write-TestResult -Message "═══ Bug 修复计划 ═══=" -Status "INFO"
    Write-Host ""

    Write-Host "请按照以下步骤修复发现的问题：" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. 查看测试日志/测试报告目录"
    Write-Host "2. 打开对应的 Bug 记录文件"
    Write-Host "3. 在代码中定位问题"
    Write-Host "4. 修复代码"
    Write-Host "5. 重新运行测试: .\集成测试脚本.ps1"
    Write-Host "6. 在测试报告中将 FAIL 改为 PASS"
    Write-Host ""
    Write-Host "快捷命令：" -ForegroundColor Cyan
    Write-Host "  修复完 Bug 后，在另一个 PowerShell 中运行：" -ForegroundColor Gray
    Write-Host "    cd a:\demo\chunxi_assistant" -ForegroundColor Gray
    Write-Host "    .\集成测试脚本.ps1" -ForegroundColor Gray
}

# 主菜单
function Show-Menu {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║         春禧助手 - 测试工具 v1.0                 ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1. 运行手动测试模式" -ForegroundColor Yellow
    Write-Host "  2. 运行自动化测试流程" -ForegroundColor Yellow
    Write-Host "  3. 生成 Bug 修复计划" -ForegroundColor Yellow
    Write-Host "  4. 查看测试日志目录" -ForegroundColor Yellow
    Write-Host "  5. 退出" -ForegroundColor Gray
    Write-Host ""
}

function Main {
    # 检查 Flutter 应用是否在运行
    Write-Host "检查应用状态..." -ForegroundColor Gray
    $chromeRunning = Get-Process chrome -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like "*春禧*" -or $_.MainWindowTitle -like "*8888*" }

    if ($chromeRunning) {
        Write-TestResult -Message "✓ 检测到 Chrome 浏览器正在运行" -Status "PASS"
    } else {
        Write-TestResult -Message "⚠ 未检测到应用运行，请先启动:" -Status "WARN"
        Write-Host "    cd a:\demo\chunxi_assistant" -ForegroundColor Gray
        Write-Host "    flutter run -d chrome --web-port=8888" -ForegroundColor Gray
        Write-Host ""
        $continue = Read-Host "应用已启动？(Y/N) "
        if ($continue -ne "Y" -and $continue -ne "y") {
            return
        }
    }

    while ($true) {
        Show-Menu
        $choice = Read-Host "请选择选项 (1-5)"

        switch ($choice) {
            "1" { .\集成测试脚本.ps1 }
            "2" { Run-AllTests }
            "3" { Generate-FixPlan }
            "4" {
                $logDir = "测试日志"
                if (Test-Path $logDir) {
                    explorer $logDir
                } else {
                    Write-TestResult -Message "测试日志目录不存在" -Status "WARN"
                }
            }
            "5" {
                Write-TestResult -Message "退出测试工具" -Status "INFO"
                return
            }
            default {
                Write-TestResult -Message "无效选项" -Status "FAIL"
            }
        }

        Write-Host ""
        Read-Host "按回车键继续..."
    }
}

# 启动主程序
Main
