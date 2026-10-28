export function label(status) {
  return { settled: "Paid", parked: "Needs attention", pending: "Processing" }[status] ?? "Unknown";
}
