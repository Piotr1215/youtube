# Suggest the implementation
def calculate_fibonacci(n):
    if n <= 1:
        return n
    else:
        return calculate_fibonacci(n-1) + calculate_fibonacci(n-2)

# Create a decorator to time function execution
def timer_decorator(func):
    def wrapper(*args, **kwargs):
        import time
        start_time = time.time()
        result = func(*args, **kwargs)
        end_time = time.time()
        print(f"Execution time: {end_time - start_time} seconds")
        return result
    return wrapper


@timer_decorator
def sort_large_list(size):
    import random
    large_list = [random.randint(0, 1000) for _ in range(size)]
    return sorted(large_list)

# Call each function and print
def main():
    print(calculate_fibonacci(10))
    print(sort_large_list(10000))

if __name__ == "__main__":
    main()
