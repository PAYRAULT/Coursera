rm -f ~/.logdb
rm -f log1

  ./logappend -T 1  -K secret -A -E Fred log1
  ./logappend -T 3  -K secret -A -E Fred -R 1 log1
  ./logappend -T 5  -K secret1 -L -E Fred -R 1 log1
  ./logappend -T 7  -K secret -L -E Fred -R 1 log1
  ./logread -K secret -S log1
  ./logread -K secret1 -S log1
  ./logread -K secret -R -E Fred log1
  
