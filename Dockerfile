FROM python:3.9
WORKDIR /
COPY get_stock_price.py ./
RUN /usr/local/bin/python3.9 -m pip install --upgrade pip
RUN pip install --no-cache-dir --upgrade requests beautifulsoup4
# We run this with a shell to allow for the variable expansion
CMD ["python3.9", "get_stock_price.py"]
