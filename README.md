# CSCI461 — Assignment 1: Dockerized SMS Spam Analysis

**Nile University · Introduction to Big Data · Fall 2026**  
**Dataset:** UCI SMS Spam Collection  
**Docker image:** `bd-a1:final`  
**Docker Hub repository:** [`donyamousa/bd-a1`](https://hub.docker.com/r/donyamousa/bd-a1)  

## 1. Project overview

This project demonstrates a reproducible, Docker-based data science workflow using SMS messages labeled **ham** (legitimate) and **spam**. The Jupyter notebook covers data understanding, cleaning, transformations, sampling, correlation analysis, text preprocessing, token frequencies, group comparisons, supervised text classification with TF-IDF, and unsupervised K-Means clustering. Generated data, reports, and figures are written to a host-mounted `output/` folder.

**Workflow:** `Dockerfile → image → container → JupyterLab → preprocessing → sampling → text analysis → TF-IDF → classification and K-Means → persistent outputs → Docker Hub`.

## 2. Project structure

```text
bd-a1-main/
├── Dockerfile
├── requirements.txt
├── README.md
├── .dockerignore
├── .gitignore
├── data/
│   ├── dataset.csv
│   └── SMSSpamCollection_readme.txt
├── notebook/
│   └── analysis.ipynb
├── output/
│   ├── cleaned_data.csv
│   ├── model_metrics.txt
│   ├── cluster_summary.txt
│   └── figures/
│       ├── correlation_heatmap.png
│       ├── word_frequency_top20.png
│       ├── group_comparison_spam_vs_ham.png
│       ├── confusion_matrices.png
│       ├── model_comparison.png
│       ├── sampling_comparison.png
│       ├── length_distribution.png
│       ├── kmeans_k_selection.png
│       └── kmeans_clusters_vs_labels.png
└── screenshots/
  ├── 01_docker-build.png
  ├── 02_docker-images.png
  ├── 03_docker-ps-runn.png
  ├── 04_docker-ps-a.png
  ├── 05_docker-logs.png
  ├── 06_docker-inspect.png
  ├── 07_jupyterlab-notebook.png
  ├── 08_docker-hub-final-tag.png
```

The project files, including the dataset and notebook, were prepared on the host before building the Docker image. The Dockerfile copies the dataset and notebook into `/home/jovyan/bd-a1/`.

## 3. Dataset and data preparation

- **Source:** [UCI Machine Learning Repository — SMS Spam Collection, dataset 228](https://archive.ics.uci.edu/dataset/228/sms+spam+collection).
- **Original contributors:** T. A. Almeida and J. M. Gómez Hidalgo; further provenance is in `data/SMSSpamCollection_readme.txt`.
- **Unit of observation:** One SMS message per row.
- **Columns:** `label` (ham/spam; classification target) and `message` (original text).
- **Records:** 5,574 original messages; 5,171 after removing 403 exact duplicates.
- **Cleaned distribution:** 4,518 ham and 653 spam messages.
- **Original data:** The project includes `data/dataset.csv`, so a separate download is not required when running the project from the ZIP or built image.

The original SMS Spam Collection file was converted to a CSV with `label` and `message` columns. The notebook keeps original text and creates a separate `cleaned_text` column for modeling and token analysis.

## 4. Docker environment and concepts

### 4.1 Custom image

The `Dockerfile` uses the **required base image**, `quay.io/jupyter/scipy-notebook:latest`, installs additional packages from `requirements.txt`, creates `/home/jovyan/bd-a1/`, copies `data/dataset.csv` and `notebook/analysis.ipynb`, and sets `WORKDIR /home/jovyan/bd-a1`. The Jupyter Docker Stacks base image supplies the JupyterLab startup command.

### 4.2 Image versus container

A **Docker image** is a reusable, read-only, layered blueprint containing the environment, code, and dataset. A **container** is a running or stopped instance of that image with its own writable layer. You can create multiple containers from one image. Removing a container does not remove its image.

### 4.3 Port mapping: `-p HOST_PORT:CONTAINER_PORT`

JupyterLab listens on port `8888` **inside** the container. With `-p 8888:8888`, the first `8888` is the port on the host Mac and the second is the container port. To avoid a busy host port, use `-p 9999:8888` and open port `9999` in the browser instead.

### 4.4 Persistent output and bind mounts

The option `-v "$(pwd)/output:/home/jovyan/bd-a1/output"` is a **bind mount**. It maps the current project directory's `output/` folder on the Mac into the container. The notebook's saved CSV, metrics, text files and figures therefore remain accessible on the host even after the container stops or is removed. A Docker **named volume** also persists, but Docker manages its storage location; a bind mount gives direct access to the required submission folder.

## 5. Build and run on macOS/Linux

**Prerequisites:** Docker Desktop (or Docker Engine), an available host port, and the extracted project folder. All commands below start from the folder containing `Dockerfile`.

### 5.1 Build the image

```bash
docker info
docker build -t bd-a1:final .
docker images
```

### 5.2 Create the output folder and run JupyterLab

```bash
mkdir -p output/figures

docker run -d \
  --name bd-a1-container \
  -p 8888:8888 \
  -v "$(pwd)/output:/home/jovyan/bd-a1/output" \
  bd-a1:final
```

If the same name is already used by a **stopped** container, inspect it first with `docker ps -a`, then remove only that old container with `docker rm bd-a1-container`. If it is running, use its existing JupyterLab session or stop it intentionally before recreating it. The commands above do **not** remove unrelated containers (e.g., MongoDB).

### 5.3 Open JupyterLab

```bash
docker ps
docker logs bd-a1-container
```

Copy the actual token-bearing URL from `docker logs` into your browser (typically `http://127.0.0.1:8888/lab?token=...`). Do not publish Jupyter tokens or credentials in screenshots or a public repository. In JupyterLab:

1. Open `notebook/analysis.ipynb`.
2. Choose **Kernel → Restart Kernel and Run All Cells** (or equivalent Run menu option).
3. Confirm **every cell runs without error**, then inspect the last cell outputs.
4. Verify `output/cleaned_data.csv`, `output/model_metrics.txt`, `output/cluster_summary.txt`, and at least four files in `output/figures/` on the **host**.

**Optional notebook persistence:** The required bind mount saves the generated `output/` files, not changes to the notebook itself. To save notebook edits back to the host when creating a container, also add `-v "$(pwd)/notebook:/home/jovyan/bd-a1/notebook"`.

### 5.4 Verify lifecycle and persistent files

While the container is running, execute in a **second terminal**:

```bash
docker images
docker ps
docker ps -a
docker logs bd-a1-container
docker inspect bd-a1-container
docker inspect -f '{{json .Mounts}}' bd-a1-container
ls -l output/
ls -l output/figures/
```

After capturing running-container screenshots, you may stop and remove **only** the assignment container and check that outputs remain:

```bash
docker stop bd-a1-container
docker ps -a
docker rm bd-a1-container
ls -l output/
```

If you want a stopped container visible in `docker ps -a`, take that screenshot **after stopping but before removing** it.

## 6. Docker Hub: push and team reproduction

The repository and tag used by this project are:

- **Repository:** `donyamousa/bd-a1`
- **Tag:** `final`
- **Page:** https://hub.docker.com/r/donyamousa/bd-a1

From the machine where `bd-a1:final` was built:

```bash
docker login
docker tag bd-a1:final donyamousa/bd-a1:final
docker push donyamousa/bd-a1:final
```

**Before marking as complete:** confirm the push prints a final digest and the `final` tag appears on Docker Hub. A tag command alone does not publish the image.

### Teammate pull-and-run validation (required)

A **different team member** must run the following on their computer (macOS/Linux), ideally without using your local build:

```bash
docker pull donyamousa/bd-a1:final
mkdir -p output/figures

docker run -d \
  --name bd-a1-teammate-test \
  -p 8888:8888 \
  -v "$(pwd)/output:/home/jovyan/bd-a1/output" \
  donyamousa/bd-a1:final

docker logs bd-a1-teammate-test
```

The teammate opens JupyterLab using the URL in the logs, runs `notebook/analysis.ipynb` with **Restart Kernel and Run All Cells**, confirms the generated files appear under their host `output/`, and captures evidence of successful reproduction. The image already contains the dataset and notebook.

**Verification record (fill in after completing the test):**

| Check | Status / evidence |
|---|---|
| Docker Hub `final` tag visible | **Pending verification** |
| Image pulled on teammate computer | **Pending verification** |
| Notebook executes top-to-bottom in pulled image | **Pending verification** |
| Teammate's host output files generated | **Pending verification** |

## 7. Data analysis and preprocessing (Assignment Section 4)

The notebook includes:

1. **Dataset understanding:** `head`, shape, column names, data types, `info`, and descriptive statistics. One record is one labeled SMS. The raw data consist of text and a categorical label; numerical columns are engineered during analysis.
2. **Cleaning:** missing-value and duplicate inspection, removal of 403 exact duplicate rows, and before/after shape comparison. Deduplication reduces repeated-message bias and train/test leakage risks.
3. **Row/column selection:** a meaningful conditional `.loc` example, positional `.iloc`, and `.iloc` using NumPy `np.r_`.
4. **Transformations:** type conversion, label encoding, engineered text features, length binning, and normalization.
5. **Sampling:** simple random, stratified, and cluster sampling with class-distribution comparisons and explanations.
6. **Correlation:** text features such as character count, word count, unique-word count, and average word length; correlation matrix and heatmap; strong/weak relationship interpretation and a discussion of why correlation **does not imply causation**.

## 8. Text analysis (Assignment Section 5)

- Preserves `message` and creates `cleaned_text`.
- Normalizes casing and whitespace, removes unnecessary punctuation, handles missing text, and replaces relevant URLs, currency markers, phone numbers, and other numbers with meaningful tokens such as `urltoken`, `moneytoken`, `phonetoken`, and `numtoken`.
- Tokenizes cleaned messages and reports total tokens, unique words, and average words per record.
- Produces a table and bar chart for the 20 most common words, including a stop-word comparison.
- Compares **spam versus ham** using average message length, average word count, and each group's most common terms.
- Includes written insights that connect an observation to quantitative evidence and interpretation.

## 9. Machine learning (Assignment Section 6)

### 9.1 Supervised classification

- **Target:** SMS label (`spam` or `ham`).
- **Split:** Stratified 80/20 train/test split (`random_state=42`).
- **Features:** TF-IDF from `cleaned_text`, fit on training data only.
- **Algorithms:** Multinomial Naive Bayes, Logistic Regression, and a tuned Logistic Regression pipeline (bonus extension).
- **Evaluation:** accuracy, precision, recall, F1-score, ROC-AUC, classification reports and confusion matrices.

**Results from the provided `output/model_metrics.txt`:**

| Classifier | Accuracy | Spam precision | Spam recall | Spam F1 |
|---|---:|---:|---:|---:|
| Multinomial Naive Bayes | 98.07% | 98.26% | 86.26% | 91.87% |
| Logistic Regression | 98.45% | 93.89% | 93.89% | 93.89% |
| Tuned Logistic Regression | **98.65%** | **96.06%** | 93.13% | **94.57%** |

**Interpretation:** The tuned Logistic Regression achieved the highest held-out accuracy and spam F1 among these experiments. Results apply to this dataset and evaluation split; real-world SMS language, new scam patterns, and class imbalance may affect generalization.

### 9.2 K-Means clustering

The notebook represents text using TF-IDF, reduces dimensionality with TruncatedSVD, normalizes vectors, and evaluates K-Means across `k=2` through `10`. The reported choice is **k=2**, justified by the observed promotional-versus-personal grouping rather than blindly forcing a number of clusters.

**Results from the provided `output/cluster_summary.txt`:**

| Measure | Value |
|---|---:|
| Chosen k | 2 |
| Cluster 0 (mostly conversational) | 4,550 messages; 1.5% spam |
| Cluster 1 (mostly promotional) | 621 messages; 93.9% spam |
| Silhouette score | 0.0274 |
| Adjusted Rand Index vs labels | 0.879 |

The low silhouette score indicates weak geometric separation in the chosen representation despite substantial agreement with the labels. The clustering section examines representative terms, cluster sizes, composition, and their relationship to the known labels. **Cluster ID numbers are arbitrary and are not supervised class predictions.**

## 10. Required deliverables and figures

| Deliverable | Location |
|---|---|
| Full notebook | `notebook/analysis.ipynb` |
| Source dataset | `data/dataset.csv` |
| Cleaned dataset | `output/cleaned_data.csv` |
| Supervised metrics and confusion-matrix details | `output/model_metrics.txt` |
| K-Means sizes, quality measure, interpretations | `output/cluster_summary.txt` |
| Correlation heatmap | `output/figures/correlation_heatmap.png` |
| Top-20 word-frequency chart | `output/figures/word_frequency_top20.png` |
| Group comparison | `output/figures/group_comparison_spam_vs_ham.png` |
| Confusion matrices | `output/figures/confusion_matrices.png` |
| Other figures | `output/figures/` (model, sampling, length, K-Means) |
| Docker evidence | `screenshots/` |
| Submission | One ZIP containing the complete project |

