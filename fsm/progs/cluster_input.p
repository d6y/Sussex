
clusterable_file ([x 11 1], 'foo');

sysobey('cluster -g foo | xgraph -bb -tk -t \"Cluster of input for 11x1\"');
