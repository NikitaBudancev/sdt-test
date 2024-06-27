<?php

$dsn = 'mysql:host=localhost;dbname=testdb';
$username = 'root';
$password = 'test';

try {
   
    $pdo = new PDO($dsn, $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $inputFile = 'orders.txt';
    $errorFile = 'invalid_orders.txt';

    $inputFileObject = new SplFileObject($inputFile, 'r');
    $errorFileObject = new SplFileObject($errorFile, 'w');

    $batchSize = 100;
    $batch = [];

    while (!$inputFileObject->eof()) {
        $line = $inputFileObject->fgets();
        $data = explode(';', trim($line));

        if (count($data) === 3) {
            list($item_id, $customer_id, $comment) = $data;

            if (is_numeric($item_id) && is_numeric($customer_id) && !empty($comment)) {
                $batch[] = [$item_id, $customer_id, $comment];

                if (count($batch) === $batchSize) {
                    insertBatch($pdo, $batch);
                    $batch = [];
                }
            } else {
                $errorFileObject->fwrite($line . PHP_EOL);
            }
        } else {
            $errorFileObject->fwrite($line . PHP_EOL);
        }
    }

    if (count($batch) > 0) {
        insertBatch($pdo, $batch);
    }
} catch (Exception $e) {
    echo 'Error: ' . $e->getMessage();
}

function insertBatch($pdo, $batch)
{
    $values = [];
    $placeholders = [];
    foreach ($batch as $row) {
        $placeholders[] = '(?, ?, ?)';
        $values = array_merge($values, $row);
    }

    $sql = "INSERT INTO reviews (type_id, customer_id, comment) VALUES " . implode(', ', $placeholders);
    $stmt = $pdo->prepare($sql);
    $stmt->execute($values);
}
