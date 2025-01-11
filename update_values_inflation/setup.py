from setuptools import setup, find_packages

setup(
    name='update_values_inflation',
    version='0.1',
    packages=find_packages(),
    install_requires=[
        # List any dependencies here
    ],
    author='Your Name',
    author_email='your.email@example.com',
    description='A package to update values based on inflation',
    long_description=open('README.md').read(),
    long_description_content_type='text/markdown',
    url='https://github.com/yourusername/update_values_inflation',  # Optional
    classifiers=[
        'Programming Language :: Python :: 3',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
    ],
    python_requires='>=3.6',
)
