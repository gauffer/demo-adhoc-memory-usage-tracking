import pandas as pd
import matplotlib.pyplot as plt

def plot_memory_usage(file_paths, labels, output_file):
    plt.figure(figsize=(10, 6))

    for file_path, label in zip(file_paths, labels):
        data = pd.read_csv(file_path)
        data['Timestamp'] = pd.to_datetime(data['Timestamp'], unit='s')
        data['Elapsed_Time'] = (data['Timestamp'] - data['Timestamp'].min()).dt.total_seconds()
        data['VmRSS_MB'] = data['VmRSS_KB'] / 1024
        plt.plot(data['Elapsed_Time'], data['VmRSS_MB'], label=label)

    plt.xlabel('Elapsed Time (s)')
    plt.ylabel('Memory Usage (MB)')
    plt.title('Memory Usage Over Time (Normalized)')
    plt.legend()
    plt.grid(True)
    plt.tight_layout()

    plt.savefig(output_file)
    print(f"Plot saved to {output_file}")

file_paths = [
    'out/memory_usage_100.csv', 
    'out/memory_usage_1000.csv',
    'out/memory_usage_10000.csv',
    'out/memory_usage_20000.csv',
]
labels = ['100 RPS', '1000 RPS', '10000 RPS', '20000 RPS']

output_file = 'out/memory_usage_plot_normalized.png'

plot_memory_usage(file_paths, labels, output_file)

