#!/usr/bin/env python3
import re
import sys
import csv

def process_file(file_path, writer, header_written=False):
    # Read the file
    with open(file_path, 'r') as f:
        lines = f.readlines()

    # Extract table data
    table_start = None
    table_end = None
    metadata_lines = []

    for i, line in enumerate(lines):
        if re.match(r'^-+\+-+\+-+\+', line) and table_start is None:
            table_start = i
        elif re.match(r'^-+\+-+\+-+\+', line) and table_start is not None:
            table_end = i
        elif line.startswith('@'):
            metadata_lines.append(line.strip())

    if table_start is None or table_end is None:
        print("Error: Could not find table in the input file.")
        return

    # Extract headers
    header_line = lines[table_start + 1].strip()
    headers = [h.strip() for h in re.split(r'\s*\|\s*', header_line.strip('|'))]

    # Extract data rows
    data_rows = []
    for i in range(table_start + 2, table_end):
        line = lines[i].strip()
        if not line or re.match(r'^-+\+-+\+-+\+', line):
            continue

        # Split by at least one whitespace followed by at least one whitespace
        row_data = []
        parts = re.split(r'\s+', line.strip())

        # The first column might contain spaces, so we need to handle it separately
        current_value = ""
        for part in parts:
            if len(row_data) == 0:
                if part.strip() and (part.strip() in ['ok', 'abort', '--'] or part.isdigit() or 'e+' in part or '-' in part):
                    row_data.append(current_value.strip())
                    row_data.append(part)
                    current_value = ""
                else:
                    current_value += " " + part if current_value else part
            else:
                row_data.append(part)

        if current_value and not row_data:
            row_data.append(current_value.strip())

        # Ensure we have the right number of columns
        while len(row_data) < len(headers):
            row_data.append("")

        data_rows.append(row_data[:len(headers)])

    # Extract metadata
    metadata = {}
    metadata_keys = {
        '01': 'solver',
        '02': 'timelimit',
        '03': 'source'
    }

    for line in metadata_lines:
        match = re.match(r'@(\d+)\s+(.*)', line)
        if match:
            id_num = match.group(1)
            content = match.group(2)

            # Use the predefined key names based on the ID number
            if id_num in metadata_keys:
                key = metadata_keys[id_num]
                value = content.split(':', 1)[1].strip() if ':' in content else content.strip()
                metadata[key] = value

    # Add metadata columns to headers
    for key in metadata:
        if key not in headers:
            headers.append(key)

    # Add metadata values to each row
    for row in data_rows:
        for key, value in metadata.items():
            row.append(value)

    # Output as CSV
    if not header_written:
        writer.writerow(headers)
        return headers, data_rows, True
    else:
        return headers, data_rows, header_written

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <input_file1> [<input_file2> ...]")
        sys.exit(1)

    writer = csv.writer(sys.stdout)
    header_written = False
    all_headers = None

    # First pass: collect all headers from all files to ensure consistency
    all_data = []
    for file_path in sys.argv[1:]:
        try:
            # Process each file
            headers, data_rows, _ = process_file(file_path, writer, True)  # Don't write headers yet

            if all_headers is None:
                all_headers = headers
            else:
                # Add any new headers we encounter
                for header in headers:
                    if header not in all_headers:
                        all_headers.append(header)

            all_data.append((headers, data_rows))
        except Exception as e:
            print(f"Error processing file {file_path}: {e}", file=sys.stderr)

    # Write the complete header once
    if all_headers:
        writer.writerow(all_headers)

    # Second pass: write all data with consistent columns
    for headers, data_rows in all_data:
        for row in data_rows:
            # Create a full row with all headers
            full_row = []
            for header in all_headers:
                if header in headers:
                    idx = headers.index(header)
                    if idx < len(row):
                        full_row.append(row[idx])
                    else:
                        full_row.append("")
                else:
                    full_row.append("")
            writer.writerow(full_row)
