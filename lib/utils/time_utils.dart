String timeAgoFromUnix(int timestamp) {
  final now = DateTime.now();
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  final diff = now.difference(date);

  if (diff.inMinutes < 1) return 'À l’instant';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min';
  if (diff.inHours < 24) return '${diff.inHours} h';
  if (diff.inDays < 7) return '${diff.inDays} j';
  return '${date.day}/${date.month}/${date.year}';
}
