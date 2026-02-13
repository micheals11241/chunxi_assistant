# 春禧助手 - 集成测试脚本
# 版本: 1.0
# 创建日期: 2026-02-13

# 颜色输出函数
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )

    $colors = @{
        "Red"    = "31"
        "Green"  = "32"
        "Yellow" = "33"
        "Blue"   = "34"
        "Cyan"   = "36"
        "White"  = "37"
    }

    Write-Host "$([char]27)[$($colors[$Color])m${Message}$([char]27)[0m"
}

# 创建日志目录结构
function Initialize-TestEnvironment {
    $logDir = "测试日志"
    $bugDir = "$logDir\Bug记录"
    $reportDir = "$logDir\测试报告"

    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir | Out-Null
        New-Item -ItemType Directory -Path $bugDir | Out-Null
        New-Item -ItemType Directory -Path $reportDir | Out-Null
        Write-ColorOutput -Message "✓ 创建测试日志目录" -Color "Green"
    }

    return @{
        LogDir = $logDir
        BugDir = $bugDir
        ReportDir = $reportDir
    }
}

# 获取当前测试会话 ID
function Get-TestSessionId {
    $sessionId = Get-Date -Format "yyyyMMdd_HHmmss"
    return "测试会话_$sessionId"
}

# 记录 Bug
function Write-BugLog {
    param(
        [string]$TestSessionId,
        [string]$Module,
        [string]$TestName,
        [string]$Steps,
        [string]$Expected,
        [string]$Actual,
        [string]$Status
    )

    $bugFile = "测试日志\Bug记录\$TestSessionId.txt"

    $bugEntry = @"
====================================================================
【发现时间】: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
【功能模块】: $Module
【测试名称】: $TestName
【测试步骤】: $Steps
【期望结果】: $Expected
【实际结果】: $Actual
【测试状态】: $Status
====================================================================

"@

    Add-Content -Path $bugFile -Value $bugEntry -Encoding UTF8
    Write-ColorOutput -Message "✗ Bug 已记录: $Module - $TestName" -Color "Red"
}

# 记录测试通过
function Write-PassLog {
    param(
        [string]$TestSessionId,
        [string]$Module,
        [string]$TestName
    )

    $passFile = "测试日志\Bug记录\$TestSessionId.txt"

    $passEntry = @"
【通过时间】: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
【功能模块】: $Module
【测试名称】: $TestName
【测试状态】: ✓ 通过
--------------------------------------------------------------------

"@

    Add-Content -Path $passFile -Value $passEntry -Encoding UTF8
}

# 生成测试报告
function Write-TestReport {
    param(
        [string]$TestSessionId,
        [hashtable]$Results
    )

    $reportFile = "测试日志\测试报告\$TestSessionId.md"

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $totalTests = $Results.Values | Measure-Object -Property Count | Select-Object -ExpandProperty Count
    $passedTests = ($Results.Values | Where-Object { $_ -eq "通过" }).Count
    $failedTests = ($Results.Values | Where-Object { $_ -eq "失败" }).Count
    $passRate = [math]::Round(($passedTests / $totalTests) * 100, 2)

    $report = @"
# 春禧助手 - 集成测试报告

**测试时间**: $timestamp
**测试会话**: $TestSessionId
**测试人员**: 自动化测试脚本

---

## 测试概览

| 指标 | 数值 |
|------|------|
| 总测试数 | $totalTests |
| 通过数 | $passedTests |
| 失败数 | $failedTests |
| 通过率 | $passRate% |

---

## 详细测试结果

"@

    $moduleGroups = $Results.GetEnumerator() | Group-Object { $_.Key.Split('_')[0] }

    foreach ($group in $moduleGroups) {
        $moduleName = $group.Name
        $report += "`n### $moduleName`n`n"
        $report += "| 测试项 | 状态 |`n"
        $report += "|---------|------|`n"

        foreach ($item in $group.Group) {
            $statusIcon = if ($item.Value -eq "通过") { "✓" } else { "✗" }
            $statusColor = if ($item.Value -eq "通过") { "Green" } else { "Red" }
            $report += "| $($item.Key.Split('_')[1]) | $statusIcon$($item.Value) |`n"
        }
        $report += "`n"
    }

    $report += @"

---

## 已发现的 Bug

请查看 `Bug记录` 目录下的详细 Bug 记录文件。

---

**报告生成时间**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**脚本版本**: 1.0
"@

    Set-Content -Path $reportFile -Value $report -Encoding UTF8
    Write-ColorOutput -Message "✓ 测试报告已生成: $reportFile" -Color "Green"

    # 在浏览器中打开报告
    Start-Process $reportFile
}

# 检查已有的 Bug 记录
function Check-ExistingBugs {
    param([string]$TestSessionId)

    $bugDir = "测试日志\Bug记录"
    if (Test-Path $bugDir) {
        $bugFiles = Get-ChildItem -Path $bugDir -Filter "*.txt"

        if ($bugFiles.Count -gt 0) {
            Write-ColorOutput -Message "`n--- 检测到之前的 Bug 记录 ---" -Color "Yellow"
            Write-ColorOutput -Message "发现 $($bugFiles.Count) 个 Bug 记录文件：" -Color "Cyan"

            foreach ($file in $bugFiles) {
                $content = Get-Content $file.FullName -Raw -Encoding UTF8
                $bugCount = ($content | Select-String "测试状态: ✗ 失败").Count
                Write-Host "  - $($file.Name) ($bugCount 个 Bug)" -ForegroundColor Gray
            }

            Write-ColorOutput -Message "`n是否查看这些 Bug 的修复状态？(Y/N)" -Color "Yellow"
            $response = Read-Host

            if ($response -eq "Y" -or $response -eq "y") {
                $latestBugFile = $bugFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1
                notepad $latestBugFile.FullName
            }
        } else {
            Write-ColorOutput -Message "✓ 没有发现之前的 Bug 记录" -Color "Green"
        }
    }
}

# 主测试流程
function Run-IntegrationTests {
    $env = Initialize-TestEnvironment
    $testSessionId = Get-TestSessionId
    $results = @{}

    Write-ColorOutput "`n╔════════════════════════════════════════════════════════════╗" -Color "Cyan"
    Write-ColorOutput "║                  春禧助手 - 集成测试工具                     ║" -Color "Cyan"
    Write-ColorOutput "╚══════════════════════════════════════════════════════════════╝" -Color "Cyan"
    Write-Host ""

    Write-ColorOutput "测试会话 ID: $testSessionId" -Color "Blue"
    Write-ColorOutput "日志目录: $($env.LogDir)" -Color "Blue"
    Write-Host ""

    # 检查现有 Bug
    Check-ExistingBugs -TestSessionId $testSessionId

    Write-ColorOutput "`n╔══════════════════════════════════════════════════════════════╗" -Color "Cyan"
    Write-ColorOutput "║                       开始测试所有功能                          ║" -Color "Cyan"
    Write-ColorOutput "╚══════════════════════════════════════════════════════════════╝" -Color "Cyan"
    Write-Host ""

    # 模块 1: 礼簿功能测试
    Write-ColorOutput "【模块 1/3】礼簿功能" -Color "Yellow"
    Write-Host "─────────────────────────────────────────────────────────"

    $giftTests = @(
        @("GiftBook_添加收入记录", "添加收入礼金记录"),
        @("GiftBook_添加支出记录", "添加支出礼金记录"),
        @("GiftBook_快捷金额选择", "选择快捷金额"),
        @("GiftBook_修改日期", "修改记录日期"),
        @("GiftBook_添加备注", "为记录添加备注"),
        @("GiftBook_删除记录", "删除一条记录"),
        @("GiftBook_统计收入", "验证收入统计"),
        @("GiftBook_统计支出", "验证支出统计"),
        @("GiftBook_统计净额", "验证净额计算"),
        @("GiftBook_数据持久化", "刷新后数据保存")
    )

    foreach ($test in $giftTests) {
        $testId, $testName = $test
        Write-Host "  测试: $testName..." -ForegroundColor Gray -NoNewline

        # 模拟测试结果（实际需要与真实应用交互）
        $testResult = "待测试"  # 需要实际测试
        $results[$testId] = $testResult

        if ($testResult -eq "通过") {
            Write-PassLog -TestSessionId $testSessionId -Module "礼簿" -TestName $testName
            Write-Host " ✓" -ForegroundColor Green
        } elseif ($testResult -eq "失败") {
            Write-BugLog -TestSessionId $testSessionId -Module "礼簿" -TestName $testName `
                -Steps "执行测试步骤" -Expected "期望结果" -Actual "实际结果" -Status "✗ 失败"
            Write-Host " ✗" -ForegroundColor Red
        } else {
            Write-Host " ?" -ForegroundColor Yellow
        }
    }

    # 模块 2: 锦囊功能测试
    Write-ColorOutput "`n【模块 2/3】锦囊功能" -Color "Yellow"
    Write-Host "─────────────────────────────────────────────────────────"

    $tipsTests = @(
        @("TipsTab_切换到吉祥话", "切换到拜年吉祥话 Tab"),
        @("TipsTab_切换到尴尬问答", "切换到应对尴尬提问 Tab"),
        @("Tips_分类_通用", "选择通用分类"),
        @("Tips_分类_长辈", "选择长辈分类"),
        @("Tips_分类_平辈", "选择平辈分类"),
        @("Tips_分类_晚辈", "选择晚辈分类"),
        @("Tips_分类_蛇年", "选择蛇年分类"),
        @("Tips_复制吉祥话", "复制一条吉祥话"),
        @("Tips_展开问题", "展开一个尴尬问题"),
        @("Tips_复制回答", "复制一个问题回答"),
        @("Tips_SnackBar提示", "验证复制提示")
    )

    foreach ($test in $tipsTests) {
        $testId, $testName = $test
        Write-Host "  测试: $testName..." -ForegroundColor Gray -NoNewline
        $testResult = "待测试"
        $results[$testId] = $testResult

        if ($testResult -eq "通过") {
            Write-PassLog -TestSessionId $testSessionId -Module "锦囊" -TestName $testName
            Write-Host " ✓" -ForegroundColor Green
        } elseif ($testResult -eq "失败") {
            Write-BugLog -TestSessionId $testSessionId -Module "锦囊" -TestName $testName `
                -Steps "执行测试步骤" -Expected "期望结果" -Actual "实际结果" -Status "✗ 失败"
            Write-Host " ✗" -ForegroundColor Red
        } else {
            Write-Host " ?" -ForegroundColor Yellow
        }
    }

    # 模块 3: 亲戚功能测试
    Write-ColorOutput "`n【模块 3/3】亲戚功能" -Color "Yellow"
    Write-Host "─────────────────────────────────────────────────────────"

    $relativeTests = @(
        @("Relative_输入关系", "输入关系描述"),
        @("Relative_点击计算", "点击计算按钮"),
        @("Relative_显示结果", "验证结果显示"),
        @("Relative_复制结果", "复制计算结果"),
        @("Relative_快捷查询", "使用快捷查询"),
        @("Relative_使用历史", "使用搜索历史"),
        @("Relative_清空历史", "清空历史记录"),
        @("Relative_速查表", "查看关系速查表"),
        @("Relative_持久化", "刷新后历史保存")
    )

    foreach ($test in $relativeTests) {
        $testId, $testName = $test
        Write-Host "  测试: $testName..." -ForegroundColor Gray -NoNewline
        $testResult = "待测试"
        $results[$testId] = $testResult

        if ($testResult -eq "通过") {
            Write-PassLog -TestSessionId $testSessionId -Module "亲戚" -TestName $testName
            Write-Host " ✓" -ForegroundColor Green
        } elseif ($testResult -eq "失败") {
            Write-BugLog -TestSessionId $testSessionId -Module "亲戚" -TestName $testName `
                -Steps "执行测试步骤" -Expected "期望结果" -Actual "实际结果" -Status "✗ 失败"
            Write-Host " ✗" -ForegroundColor Red
        } else {
            Write-Host " ?" -ForegroundColor Yellow
        }
    }

    # 生成测试报告
    Write-Host ""
    Write-ColorOutput "╔══════════════════════════════════════════════════════════════╗" -Color "Cyan"
    Write-ColorOutput "║                   生成测试报告                               ║" -Color "Cyan"
    Write-ColorOutput "╚══════════════════════════════════════════════════════════════╝" -Color "Cyan"
    Write-Host ""

    Write-TestReport -TestSessionId $testSessionId -Results $results

    Write-ColorOutput "`n✓ 测试完成！请查看报告。" -Color "Green"
}

# 手动测试模式
function Start-ManualTest {
    $env = Initialize-TestEnvironment
    $testSessionId = Get-TestSessionId

    Write-ColorOutput "`n╔══════════════════════════════════════════════════════════════╗" -Color "Cyan"
    Write-ColorOutput "║                  春禧助手 - 手动测试模式                     ║" -Color "Cyan"
    Write-ColorOutput "╚════════════════════════════════════════════════════════════╝" -Color "Cyan"
    Write-Host ""

    Write-ColorOutput "测试会话 ID: $testSessionId" -Color "Blue"
    Write-ColorOutput "Bug 记录文件: 测试日志\Bug记录\$testSessionId.txt" -Color "Blue"
    Write-Host ""

    Write-ColorOutput "请按照以下清单进行手动测试，使用以下命令记录测试结果：" -Color "Yellow"
    Write-Host ""

    Write-Host "【记录 Bug】" -ForegroundColor Cyan
    Write-Host "  添加Bug: function Add-Bug"
    Write-Host "  使用示例: Add-Bug -Module '礼簿' -TestName '添加记录' -Steps '点击添加按钮...' -Expected '记录添加成功' -Actual '按钮无响应' -Status '失败'"
    Write-Host ""

    Write-Host "【记录通过】" -ForegroundColor Cyan
    Write-Host "  添加通过: function Add-Pass"
    Write-Host "  使用示例: Add-Pass -Module '礼簿' -TestName '添加记录'"
    Write-Host ""

    Write-Host "【生成报告】" -ForegroundColor Cyan
    Write-Host "  生成报告: function New-Report"
    Write-Host ""

    Write-ColorOutput "测试清单 (在浏览器中逐项测试):`n" -Color "Yellow"

    Write-Host "【模块 1: 礼簿功能】" -ForegroundColor Yellow
    Write-Host "  1. 添加收入记录"
    Write-Host "  2. 添加支出记录"
    Write-Host "  3. 使用快捷金额选择"
    Write-Host "  4. 修改日期选择器"
    Write-Host "  5. 添加备注信息"
    Write-Host "  6. 左滑删除记录"
    Write-Host "  7. 验证统计卡片数据"
    Write-Host "  8. 刷新页面验证数据持久化"
    Write-Host ""

    Write-Host "【模块 2: 锦囊功能】" -ForegroundColor Yellow
    Write-Host "  1. 切换到拜年吉祥话 Tab"
    Write-Host "  2. 切换到应对尴尬提问 Tab"
    Write-Host "  3. 测试所有分类（通用、长辈、平辈、晚辈、蛇年）"
    Write-Host "  4. 复制一条吉祥话"
    Write-Host "  5. 展开/收起尴尬问题"
    Write-Host "  6. 复制问题回答"
    Write-Host "  7. 验证复制提示 SnackBar"
    Write-Host ""

    Write-Host "【模块 3: 亲戚功能】" -ForegroundColor Yellow
    Write-Host "  1. 输入关系描述"
    Write-Host "  2. 点击计算按钮"
    Write-Host "  3. 验证计算结果显示"
    Write-Host "  4. 复制计算结果"
    Write-Host "  5. 点击快捷查询按钮"
    Write-Host "  6. 使用历史记录"
    Write-Host "  7. 清空历史记录"
    Write-Host "  8. 查看关系速查表"
    Write-Host "  9. 刷新页面验证历史持久化"
    Write-Host ""

    Write-ColorOutput "测试浏览器地址: http://127.0.0.1:8888`n" -Color "Blue"
    Write-ColorOutput "提示: 在测试时，在另一个 PowerShell 窗口中运行测试命令记录结果。" -Color "Cyan"
}

# Bug 记录函数（手动测试用）
function Add-Bug {
    param(
        [Parameter(Mandatory)]
        [string]$Module,

        [Parameter(Mandatory)]
        [string]$TestName,

        [Parameter(Mandatory)]
        [string]$Steps,

        [Parameter(Mandatory)]
        [string]$Expected,

        [Parameter(Mandatory)]
        [string]$Actual,

        [Parameter()]
        [string]$Status = "失败"
    )

    $testSessionId = Get-TestSessionId
    Write-BugLog -TestSessionId $testSessionId -Module $Module -TestName $TestName -Steps $Steps -Expected $Expected -Actual $Actual -Status $Status
}

# 通过记录函数（手动测试用）
function Add-Pass {
    param(
        [Parameter(Mandatory)]
        [string]$Module,

        [Parameter(Mandatory)]
        [string]$TestName
    )

    $testSessionId = Get-TestSessionId
    Write-PassLog -TestSessionId $testSessionId -Module $Module -TestName $TestName
    Write-ColorOutput "✓ 已记录: $Module - $TestName" -Color "Green"
}

# 生成报告函数（手动测试用）
function New-Report {
    $testSessionId = Get-TestSessionId
    $bugFile = "测试日志\Bug记录\$testSessionId.txt"

    if (Test-Path $bugFile) {
        # 解析 Bug 文件生成结果
        $content = Get-Content $bugFile -Encoding UTF8
        $results = @{}

        foreach ($line in $content) {
            if ($line -match "【功能模块】:\s*(.+)") {
                $module = $matches[1]
            }
            if ($line -match "【测试状态】:\s*✓\s*通过") {
                if ($module -and $line -match "【测试名称】:\s*(.+)") {
                    $testName = $matches[1]
                    $results["${module}_$testName"] = "通过"
                }
            }
        }

        Write-TestReport -TestSessionId $testSessionId -Results $results
    } else {
        Write-ColorOutput "✗ 未找到 Bug 记录文件，请先执行一些测试。" -Color "Red"
    }
}

# 主菜单
function Show-Menu {
    Write-Host ""
    Write-ColorOutput "请选择测试模式：" -Color "Cyan"
    Write-Host "  1. 手动测试模式（推荐，实际在浏览器中操作并记录）"
    Write-Host "  2. 自动化测试模式（模拟测试流程）"
    Write-Host "  3. 生成测试报告"
    Write-Host "  4. 查看历史 Bug 记录"
    Write-Host "  5. 退出"
    Write-Host ""
}

# 主程序入口
function Main {
    Show-Menu
    $choice = Read-Host "请输入选项 (1-5)"

    switch ($choice) {
        "1" { Start-ManualTest }
        "2" { Run-IntegrationTests }
        "3" { New-Report }
        "4" {
            $logDir = "测试日志\Bug记录"
            if (Test-Path $logDir) {
                $files = Get-ChildItem -Path $logDir -Filter "*.txt" | Sort-Object LastWriteTime -Descending
                if ($files.Count -gt 0) {
                    Write-ColorOutput "`n历史 Bug 记录：`n" -Color "Yellow"
                    foreach ($file in $files | Select-Object -First 5) {
                        $content = Get-Content $file.FullName -Encoding UTF8 | Select-Object -First 5
                        Write-Host "`n文件: $($file.Name)" -ForegroundColor Cyan
                        Write-Host $content
                        Write-Host "..."
                    }
                } else {
                    Write-ColorOutput "没有历史 Bug 记录" -Color "Gray"
                }
            } else {
                Write-ColorOutput "Bug 记录目录不存在" -Color "Red"
            }
        }
        "5" {
            Write-ColorOutput "退出测试工具" -Color "Yellow"
            return
        }
        default {
            Write-ColorOutput "无效选项，请重新选择" -Color "Red"
            Main
        }
    }

    # 返回菜单（除非退出）
    if ($choice -ne "5") {
        Write-Host ""
        Read-Host "按回车键返回菜单..."
        Main
    }
}

# 导出函数供外部使用（如需导入此脚本为模块）
# Export-ModuleMember -Function Add-Bug, Add-Pass, New-Report, Initialize-TestEnvironment, Get-TestSessionId, Check-ExistingBugs

# 如果直接运行脚本，显示菜单
if ($MyInvocation.InvocationName -eq $MyInvocation.MyCommand.Name) {
    Main
}
