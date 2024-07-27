import os
import re
import jinja2

# Path Configuration
log_directory = 'tests/test_suites/test_report/template/logs'
screenshot_directory = os.path.join(
    os.getcwd(), 'tests/test_suites/test_report/screenshots')
output_file_path = 'tests/test_suites/test_report/test_report.html'

# Initialize Jinja2 template environment
template_loader = jinja2.FileSystemLoader(searchpath='./')
template_env = jinja2.Environment(loader=template_loader)
template = template_env.get_template(
    'tests/test_suites/test_report/template/report_template.html')

lines_with_timings_exceptions_or_separator = []
prev_ztm_time = None
total_execution_time = 0
test_suites_count = 0
pass_count = 0
fail_count = 0

# Regular expression patterns, what to include & exclude
time_pattern = r'\b\d{2}:\d{2}\b'
exclude_pattern = '|'.join(
    map(re.escape, ["FlutterDriverExtension", "flutter:", "asynchronous gap", "LateInitializationError:", "Unhandled Exception:"]))

# Mapping test suites to screenshot names
test_suite_screenshot_mapping = {
    "verify_diary_meals_test": "Diary_Meals_Test",
    "verify_diary_training_test": "Diary_Training_Test",
    # Add more mappings as needed
}

# Process log files
for log_file_path in [os.path.join(log_directory, filename) for filename in os.listdir(log_directory) if filename.endswith('.log')]:
    log_name = os.path.splitext(os.path.basename(log_file_path))[0]
    lines_with_timings_exceptions_or_separator.append(
        f"===== {log_name} test suite results =====")

    try:
        log_lines = open(log_file_path, 'r').read().splitlines()
    except Exception as e:
        print(f"Error reading log file '{log_file_path}': {e}")
        break

    i = 0
    screenshot_name = None

    # Process each line in log files
    while i < len(log_lines):
        line = log_lines[i]

        if re.search(f"{time_pattern}|Exception:|^=====.*=====$", line) and not re.search(exclude_pattern, line):

            if "ZTM-" in line or "setUpAll" in line or "tearDownAll" in line or "Exception:" in line:
                # Timing handling and extracting all ZTMs
                match = re.search(r'(\d{2}:\d{2})', line)
                if match:
                    current_ztm_time = match.group(1)
                    if prev_ztm_time:
                        current_minutes, current_seconds = map(
                            int, current_ztm_time.split(':'))
                        prev_minutes, prev_seconds = map(
                            int, prev_ztm_time.split(':'))
                        time_difference = (
                            current_minutes - prev_minutes) * 60 + (current_seconds - prev_seconds)
                        formatted_time = f'{time_difference // 60:02}:{time_difference % 60:02}'
                        colored_formatted_time = f'<span style="color: #ff223f;">[{formatted_time}]</span>'
                        lines_with_timings_exceptions_or_separator.append(
                            f"{prev_ztm_line} {colored_formatted_time}")
                    prev_ztm_time = current_ztm_time
                    prev_ztm_line = line
                    split_parts = prev_ztm_line.split(": ", 1)
                    if len(split_parts) >= 2:
                        prev_ztm_line = split_parts[1].strip()
                # Extracting Exception lines
                if "Exception:" in line:
                    lines_with_timings_exceptions_or_separator.append(line)
                    for j in range(12):
                        next_line = log_lines[i + j + 1] if i + \
                            j + 1 < len(log_lines) else None
                        if next_line and "ZTM-" in next_line:
                            break
                        elif next_line and "test" in next_line:
                            lines_with_timings_exceptions_or_separator.append(
                                next_line)
                    i += 12  # Don't increase the count
            elif "Some tests failed." in line or "All tests passed!" in line:
                # Fetching Pass/Fail count
                timing_match = re.search(r'(\d{2}:\d{2})', line)
                pass_match = re.search(r'\+(\d+)', line)
                fail_match = re.search(r'-(\d+)', line)
                if timing_match:
                    timing_parts = timing_match.group(1).split(':')
                    timing_minutes = int(
                        timing_parts[0]) * 60 + int(timing_parts[1])
                    total_execution_time += timing_minutes
                if pass_match:
                    pass_count += int(pass_match.group(1))
                if fail_match:
                    fail_count += int(fail_match.group(1))

            # Fetching screenshots
            if "[E]" in line:
                # Determine the test suite name from the log name
                test_suite_name = log_name
                if test_suite_name in test_suite_screenshot_mapping:
                    screenshot_name = test_suite_screenshot_mapping[test_suite_name]
                else:
                    screenshot_name = None
            elif screenshot_name:
                screenshot_full_path = os.path.join(
                    screenshot_directory, f"{screenshot_name}.png")
                if os.path.exists(screenshot_full_path):
                    lines_with_timings_exceptions_or_separator.append(
                        f'<img src="{screenshot_full_path}" alt="Screenshot" style="max-width:100%; height:auto;">')
                screenshot_name = None
            i += 1
        else:
            i += 1
    test_suites_count += 1

# Remove unnecessary lines and escape ANSI sequences
lines_with_timings_exceptions_or_separator = [
    line
    for line in lines_with_timings_exceptions_or_separator
    if not ("setUp" in line or "tearDown" in line or "[E]" in line or "[00:00]" in line)
]
ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
cleaned_lines = [ansi_escape.sub('', line)
                 for line in lines_with_timings_exceptions_or_separator]

# Insert statistics into the report template
html_content = template.render(
    lines=cleaned_lines,
    test_suites_count=test_suites_count,
    pass_count=pass_count,
    fail_count=fail_count,
    total_execution_time=f"{total_execution_time // 60} minutes {total_execution_time % 60} seconds"
)

# Write the generated report to an HTML file
with open(output_file_path, 'w') as html_file:
    html_file.write(html_content)

print(f"Report generated and saved to {output_file_path}")
