
.. include:: ../common/common_definitions.rst

.. _pid_eaa_data_model.rst:

PID/(Q)EAA Data Model
+++++++++++++++++++++

The Digital Credential Data Model structures Digital Credentials for secure, interoperable use. Key elements include:

    - Credential Subject: The individual or entity receiving the Credential.
    - Issuer: The PID/(Q)EAA Provider issuing and signing the Credential.
    - Metadata: Details about the Credential, like type and validity.
    - Claims: Information about the subject, such as identity or qualifications.
    - Proof: Cryptographic verification of authenticity and legitimate ownership.

The Person Identification Data (PID) is issued by the PID Provider according to national laws. The main scope of the PID is allowing natural persons to be authenticated for the access to a service or to a protected resource. 
The User attributes provided within the Italian PID are the ones listed below:

    - Current Family Name
    - Current First Name
    - Date of Birth
    - Taxpayer identification number

The (Q)EAAs are issued by (Q)EAA Issuers to a Wallet Instance and MUST be provided in SD-JWT-VC or MDOC-CBOR data format. 

The PID/(Q)EAA data format and the mechanism through which a digital credential is issued to the Wallet Instance and presented to a Relying Party are described in the following sections. 

SD-JWT-VC Credential Format
===========================

The PID/(Q)EAA is issued in the form of a Digital Credential. The Digital Credential format is `SD-JWT`_ as specified in `SD-JWT-VC`_.

SD-JWT MUST be signed using the Issuer's private key. SD-JWT MUST be provided along with a Type Metadata related to the issued Digital Credential according to Sections 6 and 6.3 of [`SD-JWT-VC`_]. The payload MUST contain the **_sd_alg** claim described in the Section 4.1.1 `SD-JWT`_ and other claims specified in this section. 

The claim **_sd_alg** indicates the hash algorithm used by the Issuer to generate the digests as described in Section 4.1.1 of `SD-JWT`_. **_sd_alg**  MUST be set to one of the specified algorithms in Section :ref:`Cryptographic Algorithms <supported_algs>`.

Claims that are not selectively disclosable MUST be included in the SD-JWT as they are.  The digests of the disclosures, along with any decoy if present,  MUST be contained in the  **_sd** array, as specified in Section 4.2.4.1 of `SD-JWT`_. 

Each digest value, calculated using a hash function over the disclosures, verifies the integrity and corresponds to a specific Disclosure. Each disclosure includes:

  - a random salt, 
  - the claim name (only when the claim is an object element), 
  - the claim value. 

In case of nested object in a SD-JWT payload each claim, on each level of the JSON, should be individually selectively disclosable or not. Therefore **_sd** claim containing digests MAY appear multiple times at different level in the SD-JWT.

For each claim that is an array element the digests of the respective disclosures and decoy digests are added to the array in the same position of the original claim values as specified in Section 4.2.4.2 of `SD-JWT`_.

In case of array elements, digest values are calculated using a hash function over the disclosures, containing:

  - a random salt, 
  - the array element

In case of multiple array elements, the Issuer may hide the value of the entire array or any of the entry contained within the array, the Holder can disclose both the entire array and any single entry within the array, as defined in Section 4.2.6 of `SD-JWT`_.

The Disclosures are provided to the Holder together with the SD-JWT in the *Combined Format for Issuance* that is an ordered series of base64url-encoded values, each separated from the next by a single tilde ('~') character as follows:

.. code-block::

  <Issuer-Signed-JWT>~<Disclosure 1>~<Disclosure 2>~...~<Disclosure N>

See `SD-JWT-VC`_ and `SD-JWT`_ for additional details. 


PID/(Q)EAA SD-JWT Parameters
----------------------------

The JOSE header contains the following mandatory parameters:

.. _pid_jose_header:

.. list-table:: 
  :widths: 20 60 20
  :header-rows: 1

  * - **Claim**
    - **Description**
    - **Reference**
  * - **typ**
    - REQUIRED. It MUST be set to ``dc+sd-jwt`` as defined in `SD-JWT-VC`_. 
    - :rfc:`7515` Section 4.1.9.
  * - **alg**
    - REQUIRED. Signature Algorithm. 
    - :rfc:`7515` Section 4.1.1.
  * - **kid**
    - REQUIRED. Unique identifier of the public key. 
    - :rfc:`7515` Section 4.1.8.
  * - **trust_chain**
    - OPTIONAL. JSON array containing the trust chain that proves the reliability of the issuer of the JWT. 
    - [`OID-FED`_] Section 4.3.
  * - **x5c**
    - OPTIONAL. Contains the X.509 public key certificate or certificate chain [:rfc:`5280`] corresponding to the key used to digitally sign the JWT. 
    - :rfc:`7515` Section 4.1.8 and [`SD-JWT-VC`_] Section 3.5.
  * - **vctm**
    - OPTIONAL. JSON array of base64url-encoded Type Metadata JSON documents. In case of extended type metadata, this claim contains the entire chain of JSON documents. 
    - [`SD-JWT-VC`_] Section 6.3.5.

The JWT payload contains the following claims. Some of these claims can be disclosed, these are listed in the following tables that specify whether a claim is selectively disclosable [SD] or not [NSD].

.. list-table:: 
    :widths: 20 60 20
    :header-rows: 1

    * - **Claim**
      - **Description**
      - **Reference**
    * - **iss**
      - [NSD]. REQUIRED. URL string representing the PID/(Q)EAA Issuer unique identifier.
      - `[RFC7519, Section 4.1.1] <https://www.iana.org/go/rfc7519>`_.
    * - **sub**
      - [NSD]. REQUIRED. The identifier of the subject of the Digital Credential, the User, MUST be opaque and MUST NOT correspond to any anagraphic data or be derived from the User's anagraphic data via pseudonymization. Additionally, it is required that two different Credentials issued MUST NOT use the same ``sub`` value.
      - `[RFC7519, Section 4.1.2] <https://www.iana.org/go/rfc7519>`_.
    * - **iat**
      - [SD]. REQUIRED. UNIX Timestamp with the time of JWT issuance, coded as NumericDate as indicated in :rfc:`7519`.
      - `[RFC7519, Section 4.1.6] <https://www.iana.org/go/rfc7519>`_.
    * - **exp**
      - [NSD]. REQUIRED. UNIX Timestamp with the expiry time of the JWT, coded as NumericDate as indicated in :rfc:`7519`.
      - `[RFC7519, Section 4.1.4] <https://www.iana.org/go/rfc7519>`_.
    * - **nbf**
      - [NSD]. OPTIONAL. UNIX Timestamp with the start time of validity of the JWT, coded as NumericDate as indicated in :rfc:`7519`.
      - `[RFC7519, Section 4.1.4] <https://www.iana.org/go/rfc7519>`_.    
    * - **issuing_authority**
      - [NSD]. REQUIRED. Name of the administrative authority that has issued the PID/(Q)EAA.
      - Commission Implementing Regulation `EU_2024/2977`_.
    * - **issuing_country**
      - [NSD]. REQUIRED. Alpha-2 country code, as specified in ISO 3166-1, of the country or territory of the PID/(Q)EAA Issuer.
      - Commission Implementing Regulation `EU_2024/2977`_.
    * - **status**
      - [NSD]. REQUIRED. JSON object containing the information on how to read the status of the Verifiable Credential. It MUST contain the JSON member *status_assertion* set to a JSON Object containing the *credential_hash_alg* claim indicating the Algorithm used for hashing the Digital Credential to which the Status Assertion is bound. It is RECOMMENDED to use *sha-256*. 
      - Section 3.2.2.2 `SD-JWT-VC`_ and Section 11 `OAUTH-STATUS-ASSERTION`_.
    * - **cnf**
      - [NSD]. REQUIRED. JSON object containing the proof-of-possession key materials. By including a **cnf** (confirmation) claim in a JWT, the Issuer of the JWT declares that the Holder is in control of the private key related to the public one defined in the **cnf** parameter. The recipient MUST cryptographically verify that the Holder is in control of that key.
      - `[RFC7800, Section 3.1] <https://www.iana.org/go/rfc7800>`_ and Section 3.2.2.2 `SD-JWT-VC`_.
    * - **vct**
      - [NSD]. REQUIRED. Credential type value MUST be an HTTPS URL String and it MUST be set using one of the values obtained from the PID/(Q)EAA Issuer metadata. It is the identifier of the SD-JWT VC type and it MUST be set with a collision-resistant value as defined in Section 2 of :rfc:`7515`. It MUST contain also the number of version of the Credential type (for instance: ``https://issuer.example.org/v1.0/personidentificationdata``).
      - Section 3.2.2.2 `SD-JWT-VC`_.
    * - **vct#integrity**
      - [NSD]. REQUIRED. The value MUST be an "integrity metadata" string as defined in Section 3 of [`W3C-SRI`_]. *SHA-256*, *SHA-384* and *SHA-512* MUST be supported as cryptographic hash functions. *MD5* and *SHA-1* MUST NOT be used. This claim MUST be verified according to Section 3.3.5 of [`W3C-SRI`_].
      - Section 6.1 `SD-JWT-VC`_, [`W3C-SRI`_]
    * - **verification**
      - [SD]. CONDITIONAL. REQUIRED if Credential type is set to `PersonIdentificationData`. Object containing User authentication and User data verification information. If present MUST include the following sub-value:

          * ``trust_framework``: String identifying the trust framework used for User authentication. It MUST be set using one of the values described in the `trust_frameworks_supported` map provided within the Credential Issuer Metadata.
          * ``assurance_level``: String identifying the level of identity assurance guaranteed during the User authentication process.
          * ``evidence``: Each entry of the array MUST contain the following members:
              - ``type``: It represents evidence type. It MUST be set to ``vouch``.
              - ``time``: UNIX Timestamps with the time of the authentication or verification.
              - ``attestation``: It MUST contain the following members:
                  - ``type``: It MUST be set to ``digital_attestation``.
                  - ``reference_number``: identifier of the authentication or verification response.
                  - ``date_of_issuance``: date of issuance of the attestation.
                  - ``voucher``: It MUST contains ``organization`` claim.
      - `OIDC-IDA`_.

.. note::

    Credential Type Metadata JSON Document MAY be retrieved directly from the URL contained in the claim **vct**, using the HTTP GET method or using the vctm header parameter if provided. Unlike specified in Section 6.3.1 of `SD-JWT-VC`_ the **.well-known** endpoint is not included in the current implementation profile. Implementers may decide to use it for interoperability with other systems.


Digital Credential Metadata Type
--------------------------------

The Metadata type document MUST be a JSON object and contains the following parameters.

.. list-table:: 
    :widths: 20 60 20
    :header-rows: 1

    * - **Claim**
      - **Description**
      - **Reference**
    * - **name**
      - REQUIRED. Human-readable name of the Digital Credential type. In case of multiple language, the language tags are added to member name, delimited by a # character as defined in :rfc:`5646` (e.g. *name#it-IT*).
      - [`SD-JWT-VC`_] Section 6.2 and [`OIDC`_] Section 5.2.
    * - **description**
      - REQUIRED. A human-readable description of the Digital Credential type. In case of multiple language, the language tags are added to member name, delimited by a # character as defined in :rfc:`5646`.
      - [`SD-JWT-VC`_] Section 6.2 and [`OIDC`_] Section 5.2.
    * - **extends**
      - OPTIONAL. String Identitifier of an exteded metadata type document.
      - [`SD-JWT-VC`_] Section 6.2.
    * - **extends#integrity**
      - CONDITIONAL. REQUIRED if **extends** is present.
      - [`SD-JWT-VC`_] Section 6.2.
    * - **schema**
      - CONDITIONAL. REQUIRED if **schema_uri** is not present.
      - [`SD-JWT-VC`_] Section 6.2.
    * - **schema_uri**
      - CONDITIONAL. REQUIRED if **schema** is not present.
      - [`SD-JWT-VC`_] Section 6.2.
    * - **schema_uri#integrity**
      - CONDITIONAL. REQUIRED if **schema_uri** is present.
      - [`SD-JWT-VC`_] Section 6.2.
    * - **data_source**
      - REQUIRED. Object containing information about the data origin. It MUST contain the object ``verification`` with this following sub-value:

          * ``trust_framework``: MUST contain trust framework used for digital authentication towards Authentic Source system.
          * ``authentic_source``: MUST contain the following claims related to information about the Authentic Source:
               * ``organization_name`` name of the Authentic Source.
               * ``organization_code`` code identifier of the Authentic Source.
               * ``homepage_uri`` uri pointing to the Authentic Source's homepage.
               * ``contacts`` contact list for info and assistance.
               * ``logo_uri`` URI pointing to the logo image.
      - This specification
    * - **display**
      - REQUIRED. Array of objects, one for each language supported, containing display information for the Digital Credential type. It contains for each object the following properties:

          * ``lang``: language tag as defined in :rfc:`5646` Section 2. [REQUIRED].
          * ``name``: human-readable label for the Digital Credential type. [REQUIRED].
          * ``description``: human-readable description for the Digital Credential type. [REQUIRED].
          * ``rendering``: object containing rendering methods supported by the Digital Credential type. [REQUIRED]. The rendering method `svg_template` MUST be supported.
              The ``svg_templates`` array of objects contains for each SVG template supported the following properties:
                  * ``uri``: URI pointing to the SVG template. [REQUIRED].
                  * ``uri#integrity``: integrity metadata as defined in Section 3 of `W3C-SRI`_. [REQUIRED].
                  * ``properties``: object containing SVG template properties. This property is REQUIRED if more than one SVG template is present. The object MUST contain at least one of the properties defined in `SD-JWT-VC`_ Section 8.1.2.1.
                             
              If rendering method `simple` is also supported, the ``simple`` object contains the following properties: 
                  * ``logo``: object containing information about the logo to display. This property is REQUIRED. The object contains the following sub-values:
                      * ``uri``: URI pointing to the logo image. [REQUIRED]
                      * ``uri#integrity``: integrity metadata as defined in Section 3 of `W3C-SRI`_. [REQUIRED].
                      * ``alt_text``: A string containing alternative text to display instead of the logo image. [OPTIONAL].
                  * ``background_color``: RGB color value as defined in `W3C.CSS-COLOR`_ for the background of the Digital Credential. [OPTIONAL].
                  * ``text_color``: RGB color value as defined in `W3C.CSS-COLOR`_ for the text of the Digital Credential. [OPTIONAL].

          .. note::

            The use of the SVG template is recommended for all applications that support it.

      - [`SD-JWT-VC`_] Section 8.
    * - **claims**
      - REQUIRED. Array of objects containing information for displaying and validating Digital Credential claims. It contains for each Credential claim the following properties:

          * ``path``: array indicating the claim or claims that are being addressed. [REQUIRED].
          * ``display``: array containing display information about the claim indicated in the ``path``. The array contains an object for each language supported by the Digital Credential type. This property is REQUIRED. It contains the following members:
             * ``lang``: language tag as defined in :rfc:`5646` Section 2. [REQUIRED].
             * ``label``: human-readable label for the claim. [REQUIRED].
             * ``description``: human-readable description for the claim. [REQUIRED].
          * ``sd``: string indicating whether the claim is selectively disclosable. It MUST be set to `always` if the claim is selectively disclosure or `never` if not. [REQUIRED].
          * ``svg_id``: alphanumeric string containing ID of the claim referenced in the SVG template as defined in [`SD-JWT-VC`_] Section 9. [REQUIRED].
      - [`SD-JWT-VC`_] Section 9.


A non-normative Digital Credential metadata type is provided below.

.. literalinclude:: ../../examples/vc-metadata-type.json
  :language: JSON  

.. _sec-pid-user-claims:   

PID Claims
----------

Depending on the Digital Credential type **vct**, additional claims data MAY be added. The PID supports the following data:

.. list-table:: 
    :widths: 20 60 20
    :header-rows: 1

    * - **Claim**
      - **Description**
      - **Reference**
    * - **given_name**
      - [SD]. REQUIRED. Current First Name.
      - Section 5.1 of `OIDC`_ and Commission Implementing Regulation `EU_2024/2977`_
    * - **family_name**
      - [SD]. REQUIRED. Current Family Name.
      - Section 5.1 of `OIDC`_ and Commission Implementing Regulation `EU_2024/2977`_
    * - **birth_date**
      - [SD]. REQUIRED. Date of Birth.
      - Commission Implementing Regulation `EU_2024/2977`_
    * - **birth_place**
      - [SD]. REQUIRED. Place of Birth.
      - Commission Implementing Regulation `EU_2024/2977`_
    * - **nationality**
      - [SD]. REQUIRED. One or more alpha-2 country codes as specified in ISO 3166-1.
      - Commission Implementing Regulation `EU_2024/2977`_
    * - **personal_administrative_number**
      - [SD]. CONDITIONAL. REQUIRED if ``tax_id_code`` is not present. National unique identifier of a natural person generated by ANPR as a String format.
      - Commission Implementing Regulation `EU_2024/2977`_
    * - **tax_id_code**
      - [SD]. CONDITIONAL. REQUIRED if ``personal_administrative_number`` is not present. National tax identification code of natural person as a String format. It MUST be set according to ETSI EN 319 412-1. For example ``TINIT-<ItalianTaxIdentificationNumber>``
      - 

The PID attribute schema, which encompasses all potential User data, is defined in `ARF v1.4 <https://github.com/eu-digital-identity-wallet/eudi-doc-architecture-and-reference-framework/blob/main/docs/arf.md#21-identification-and-authentication-to-access-online-services>`_, and furthermore detailed in the `PID Rulebook <https://github.com/eu-digital-identity-wallet/eudi-doc-architecture-and-reference-framework/blob/main/docs/annexes/annex-3/annex-3.01-pid-rulebook.md#23-pid-attributes>`_.


PID Non-Normative Examples
--------------------------

In the following, the non-normative example of the payload of a PID represented in JSON format.

.. literalinclude:: ../../examples/pid-json-example-payload.json
  :language: JSON  

The corresponding SD-JWT version for PID is given by

.. literalinclude:: ../../examples/pid-sd-jwt-example-header.json
  :language: JSON    

.. literalinclude:: ../../examples/pid-sd-jwt-example-payload.json
  :language: JSON  

In the following the disclosure list is given

**Claim** ``iat``:

-  SHA-256 Hash: ``Yrc-s-WSr4exEYtqDEsmRl7spoVfmBxixP12e4syqNE``
-  Disclosure:
   ``WyIyR0xDNDJzS1F2ZUNmR2ZyeU5STjl3IiwgImlhdCIsIDE2ODMwMDAwMDBd``
-  Contents: ``["2GLC42sKQveCfGfryNRN9w", "iat", 1683000000]``

**Claim** ``verification``:

-  SHA-256 Hash: ``h7Egl5H9gTPC_FCU845aadvsC--dTjy9Nrstxh-caRo``
-  Disclosure:
   ``WyJlbHVWNU9nM2dTTklJOEVZbnN4QV9BIiwgInZlcmlmaWNhdGlvbiIsIHsi``
   ``dHJ1c3RfZnJhbWV3b3JrIjogIml0X2NpZSIsICJhc3N1cmFuY2VfbGV2ZWwi``
   ``OiAiaGlnaCIsICJldmlkZW5jZSI6IHsidHlwZSI6ICJ2b3VjaCIsICJ0aW1l``
   ``IjogIjIwMjAtMDMtMTlUMTI6NDJaIiwgImF0dGVzdGF0aW9uIjogeyJ0eXBl``
   ``IjogImRpZ2l0YWxfYXR0ZXN0YXRpb24iLCAicmVmZXJlbmNlX251bWJlciI6``
   ``ICI2NDg1LTE2MTktMzk3Ni02NjcxIiwgImRhdGVfb2ZfaXNzdWFuY2UiOiAi``
   ``MjAyMC0wMy0xOVQxMjo0M1oiLCAidm91Y2hlciI6IHsib3JnYW5pemF0aW9u``
   ``IjogIk1pbmlzdGVybyBkZWxsJ0ludGVybm8ifX19fV0``
-  Contents: ``["eluV5Og3gSNII8EYnsxA_A", "verification",``
   ``{"trust_framework": "it_cie", "assurance_level": "high", "evidence": {"type": "vouch",``
   ``"time": "2020-03-19T12:42Z", "attestation": {"type":``
   ``"digital_attestation", "reference_number":``
   ``"6485-1619-3976-6671", "date_of_issuance":``
   ``"2020-03-19T12:43Z", "voucher": {"organization": "Ministero``
   ``dell'Interno"}}}}]``

**Claim** ``given_name``:

-  SHA-256 Hash: ``zVdghcmClMVWlUgGsGpSkCPkEHZ4u9oWj1SlIBlCc1o``
-  Disclosure:
   ``WyI2SWo3dE0tYTVpVlBHYm9TNXRtdlZBIiwgImdpdmVuX25hbWUiLCAiTWFy``
   ``aW8iXQ``
-  Contents: ``["6Ij7tM-a5iVPGboS5tmvVA", "given_name", "Mario"]``

**Claim** ``family_name``:

-  SHA-256 Hash: ``VQI-S1mT1Kxfq2o8J9io7xMMX2MIxaG9M9PeJVqrMcA``
-  Disclosure:
   ``WyJlSThaV205UW5LUHBOUGVOZW5IZGhRIiwgImZhbWlseV9uYW1lIiwgIlJv``
   ``c3NpIl0``
-  Contents: ``["eI8ZWm9QnKPpNPeNenHdhQ", "family_name", "Rossi"]``

**Claim** ``birth_date``:

-  SHA-256 Hash: ``s1XK5f2pM3-aFTauXhmvd9pyQTJ6FMUhc-JXfHrxhLk``
-  Disclosure:
   ``WyJRZ19PNjR6cUF4ZTQxMmExMDhpcm9BIiwgImJpcnRoX2RhdGUiLCAiMTk4``
   ``MC0wMS0xMCJd``
-  Contents: ``["Qg_O64zqAxe412a108iroA", "birth_date", "1980-01-10"]``

**Claim** ``birth_place``:

- SHA-256 Hash: ``tSL-e1nLdWOU9sFMTCUu5P1tCzxA-TW-VWbHGzYtU7E``
- Disclosure:
  ``WyJBSngtMDk1VlBycFR0TjRRTU9xUk9BIiwgImJpcnRoX3BsYWNlIiwgIlJv``
  ``bWEiXQ``
- Contents: ``["AJx-095VPrpTtN4QMOqROA", "birth_place", "Roma"]``

**Claim** ``nationality``:

- SHA-256 Hash: ``hP79TuWGBwIN0j9NH_fxn8Cvj-dNH_R7nFleeWCE2I4``
- Disclosure:
  ``WyJQYzMzSk0yTGNoY1VfbEhnZ3ZfdWZRIiwgIm5hdGlvbmFsaXR5IiwgIklU``
  ``Il0``
- Contents: ``["Pc33JM2LchcU_lHggv_ufQ", "nationality", "IT"]``

**Claim** ``personal_administrative_number``:

-  SHA-256 Hash: ``6WLNc09rBr-PwEtnWzxGKdzImjrpDxbr4qoIx838a88``
-  Disclosure:
   ``WyJHMDJOU3JRZmpGWFE3SW8wOXN5YWpBIiwgInBlcnNvbmFsX2FkbWluaXN0``
   ``cmF0aXZlX251bWJlciIsICJYWDAwMDAwWFgiXQ``
-  Contents: ``["G02NSrQfjFXQ7Io09syajA", "personal_administrative_number",``
   ``"XX00000XX"]``

**Claim** ``tax_id_code``:

-  SHA-256 Hash: ``LqrtU2rlA51U97cMiYhqwa-is685bYiOJImp8a5KGNA``
-  Disclosure:
   ``WyJsa2x4RjVqTVlsR1RQVW92TU5JdkNBIiwgInRheF9pZF9jb2RlIiwgIlRJ``
   ``TklULVhYWFhYWFhYWFhYWFhYWFgiXQ``
-  Contents: ``["lklxF5jMYlGTPUovMNIvCA", "tax_id_code",``
   ``"TINIT-XXXXXXXXXXXXXXXX"]``

The combined format for the PID issuance is given by:

.. code-block::

  eyJhbGciOiAiRVMyNTYiLCAidHlwIjogImRjK3NkLWp3dCIsICJraWQiOiAiZEI2N2dM
  N2NrM1RGaUlBZjdONl83U0h2cWswTURZTUVRY29HR2xrVUFBdyJ9.eyJfc2QiOiBbIjZ
  XTE5jMDlyQnItUHdFdG5XenhHS2R6SW1qcnBEeGJyNHFvSXg4MzhhODgiLCAiTHFydFU
  ycmxBNTFVOTdjTWlZaHF3YS1pczY4NWJZaU9KSW1wOGE1S0dOQSIsICJWUUktUzFtVDF
  LeGZxMm84Sjlpbzd4TU1YMk1JeGFHOU05UGVKVnFyTWNBIiwgIllyYy1zLVdTcjRleEV
  ZdHFERXNtUmw3c3BvVmZtQnhpeFAxMmU0c3lxTkUiLCAiaDdFZ2w1SDlnVFBDX0ZDVTg
  0NWFhZHZzQy0tZFRqeTlOcnN0eGgtY2FSbyIsICJoUDc5VHVXR0J3SU4wajlOSF9meG4
  4Q3ZqLWROSF9SN25GbGVlV0NFMkk0IiwgInMxWEs1ZjJwTTMtYUZUYXVYaG12ZDlweVF
  USjZGTVVoYy1KWGZIcnhoTGsiLCAidFNMLWUxbkxkV09VOXNGTVRDVXU1UDF0Q3p4QS1
  UVy1WV2JIR3pZdFU3RSIsICJ6VmRnaGNtQ2xNVldsVWdHc0dwU2tDUGtFSFo0dTlvV2o
  xU2xJQmxDYzFvIl0sICJleHAiOiAxODgzMDAwMDAwLCAiaXNzIjogImh0dHBzOi8vcGl
  kcHJvdmlkZXIuZXhhbXBsZS5vcmciLCAic3ViIjogIk56YkxzWGg4dURDY2Q3bm9XWEZ
  aQWZIa3hac1JHQzlYcyIsICJpc3N1aW5nX2F1dGhvcml0eSI6ICJJc3RpdHV0byBQb2x
  pZ3JhZmljbyBlIFplY2NhIGRlbGxvIFN0YXRvIiwgImlzc3VpbmdfY291bnRyeSI6ICJ
  JVCIsICJzdGF0dXMiOiB7InN0YXR1c19hc3NlcnRpb24iOiB7ImNyZWRlbnRpYWxfaGF
  zaF9hbGciOiAic2hhLTI1NiJ9fSwgInZjdCI6ICJodHRwczovL3BpZHByb3ZpZGVyLmV
  4YW1wbGUub3JnL3YxLjAvcGVyc29uaWRlbnRpZmljYXRpb25kYXRhIiwgInZjdCNpbnR
  lZ3JpdHkiOiAiYzVmNzNlMjUwZmU4NjlmMjRkMTUxMThhY2NlMjg2YzliYjU2YjYzYTQ
  0M2RjODVhZjY1M2NkNzNmNjA3OGIxZiIsICJfc2RfYWxnIjogInNoYS0yNTYiLCAiY25
  mIjogeyJqd2siOiB7Imt0eSI6ICJFQyIsICJjcnYiOiAiUC0yNTYiLCAieCI6ICJUQ0F
  FUjE5WnZ1M09IRjRqNFc0dmZTVm9ISVAxSUxpbERsczd2Q2VHZW1jIiwgInkiOiAiWnh
  qaVdXYlpNUUdIVldLVlE0aGJTSWlyc1ZmdWVjQ0U2dDRqVDlGMkhaUSJ9fX0.7lV6m1K
  IsnwuJcR8DgrmRHBkLEXJcx7kVBI1rzlbBwZ_xMPwAd4Dfl06dyLKegdTZO1RDR3IDi-
  JyiuNMFlZOQ~WyIyR0xDNDJzS1F2ZUNmR2ZyeU5STjl3IiwgImlhdCIsIDE2ODMwMDAw
  MDBd~WyJlbHVWNU9nM2dTTklJOEVZbnN4QV9BIiwgInZlcmlmaWNhdGlvbiIsIHsidHJ
  1c3RfZnJhbWV3b3JrIjogIml0X2NpZSIsICJhc3N1cmFuY2VfbGV2ZWwiOiAiaGlnaCI
  sICJldmlkZW5jZSI6IHsidHlwZSI6ICJ2b3VjaCIsICJ0aW1lIjogIjIwMjAtMDMtMTl
  UMTI6NDJaIiwgImF0dGVzdGF0aW9uIjogeyJ0eXBlIjogImRpZ2l0YWxfYXR0ZXN0YXR
  pb24iLCAicmVmZXJlbmNlX251bWJlciI6ICI2NDg1LTE2MTktMzk3Ni02NjcxIiwgImR
  hdGVfb2ZfaXNzdWFuY2UiOiAiMjAyMC0wMy0xOVQxMjo0M1oiLCAidm91Y2hlciI6IHs
  ib3JnYW5pemF0aW9uIjogIk1pbmlzdGVybyBkZWxsJ0ludGVybm8ifX19fV0~WyI2SWo
  3dE0tYTVpVlBHYm9TNXRtdlZBIiwgImdpdmVuX25hbWUiLCAiTWFyaW8iXQ~WyJlSTha
  V205UW5LUHBOUGVOZW5IZGhRIiwgImZhbWlseV9uYW1lIiwgIlJvc3NpIl0~WyJRZ19P
  NjR6cUF4ZTQxMmExMDhpcm9BIiwgImJpcnRoX2RhdGUiLCAiMTk4MC0wMS0xMCJd~WyJ
  BSngtMDk1VlBycFR0TjRRTU9xUk9BIiwgImJpcnRoX3BsYWNlIiwgIlJvbWEiXQ~WyJQ
  YzMzSk0yTGNoY1VfbEhnZ3ZfdWZRIiwgIm5hdGlvbmFsaXR5IiwgIklUIl0~WyJHMDJO
  U3JRZmpGWFE3SW8wOXN5YWpBIiwgInBlcnNvbmFsX2FkbWluaXN0cmF0aXZlX251bWJl
  ciIsICJYWDAwMDAwWFgiXQ~WyJsa2x4RjVqTVlsR1RQVW92TU5JdkNBIiwgInRheF9pZ
  F9jb2RlIiwgIlRJTklULVhYWFhYWFhYWFhYWFhYWFgiXQ~


(Q)EAA non-normative Examples
-----------------------------

Below a non-normative example of (Q)EAA in JSON.

.. literalinclude:: ../../examples/qeaa-json-example-payload.json
  :language: JSON  

The corresponding SD-JWT for the previous data is represented as follow, as decoded JSON for both header and payload.

.. literalinclude:: ../../examples/qeaa-sd-jwt-example-header.json
  :language: JSON  

.. literalinclude:: ../../examples/qeaa-sd-jwt-example-payload.json
  :language: JSON  

In the following the disclosure list is given:

**Claim** ``iat``:

-  SHA-256 Hash: ``Yrc-s-WSr4exEYtqDEsmRl7spoVfmBxixP12e4syqNE``
-  Disclosure:
   ``WyIyR0xDNDJzS1F2ZUNmR2ZyeU5STjl3IiwgImlhdCIsIDE2ODMwMDAwMDBd``
-  Contents: ``["2GLC42sKQveCfGfryNRN9w", "iat", 1683000000]``

**Claim** ``document_number``:

-  SHA-256 Hash: ``Dx-6hjvrcxNzF0slU6ukNmzHoL-YvBN-tFa0T8X-bY0``
-  Disclosure:
   ``WyJlbHVWNU9nM2dTTklJOEVZbnN4QV9BIiwgImRvY3VtZW50X251bWJlciIs``
   ``ICJYWFhYWFhYWFhYIl0``
-  Contents:
   ``["eluV5Og3gSNII8EYnsxA_A", "document_number", "XXXXXXXXXX"]``

**Claim** ``given_name``:

-  SHA-256 Hash: ``zVdghcmClMVWlUgGsGpSkCPkEHZ4u9oWj1SlIBlCc1o``
-  Disclosure:
   ``WyI2SWo3dE0tYTVpVlBHYm9TNXRtdlZBIiwgImdpdmVuX25hbWUiLCAiTWFy``
   ``aW8iXQ``
-  Contents: ``["6Ij7tM-a5iVPGboS5tmvVA", "given_name", "Mario"]``

**Claim** ``family_name``:

-  SHA-256 Hash: ``VQI-S1mT1Kxfq2o8J9io7xMMX2MIxaG9M9PeJVqrMcA``
-  Disclosure:
   ``WyJlSThaV205UW5LUHBOUGVOZW5IZGhRIiwgImZhbWlseV9uYW1lIiwgIlJv``
   ``c3NpIl0``
-  Contents: ``["eI8ZWm9QnKPpNPeNenHdhQ", "family_name", "Rossi"]``

**Claim** ``birth_date``:

-  SHA-256 Hash: ``s1XK5f2pM3-aFTauXhmvd9pyQTJ6FMUhc-JXfHrxhLk``
-  Disclosure:
   ``WyJRZ19PNjR6cUF4ZTQxMmExMDhpcm9BIiwgImJpcnRoX2RhdGUiLCAiMTk4``
   ``MC0wMS0xMCJd``
-  Contents: ``["Qg_O64zqAxe412a108iroA", "birth_date", "1980-01-10"]``

**Claim** ``expiry_date``:

-  SHA-256 Hash: ``aBVdfcnxT0Z5RrwdxZSUhuUxz3gM2vcEZLeYIj61Kas``
-  Disclosure:
   ``WyJBSngtMDk1VlBycFR0TjRRTU9xUk9BIiwgImV4cGlyeV9kYXRlIiwgIjIw``
   ``MjQtMDEtMDEiXQ``
-  Contents: ``["AJx-095VPrpTtN4QMOqROA", "expiry_date", "2024-01-01"]``

**Claim** ``personal_administrative_number``:

-  SHA-256 Hash: ``o1cHG8JbEEYv0HeJINYKbFLd-TnEDUuNzI1XpzV32aU``
-  Disclosure:
   ``WyJQYzMzSk0yTGNoY1VfbEhnZ3ZfdWZRIiwgInBlcnNvbmFsX2FkbWluaXN0``
   ``cmF0aXZlX251bWJlciIsICJYWDAwMDAwWFgiXQ``
-  Contents: ``["Pc33JM2LchcU_lHggv_ufQ", "personal_administrative_number",``
   ``"XX00000XX"]``

**Claim** ``constant_attendance_allowance``:

-  SHA-256 Hash: ``GE3Sjy_zAT34f8wa5DUkVB0FslaSJRAAc8I3lN11Ffc``
-  Disclosure:
   ``WyJHMDJOU3JRZmpGWFE3SW8wOXN5YWpBIiwgImNvbnN0YW50X2F0dGVuZGFu``
   ``Y2VfYWxsb3dhbmNlIiwgdHJ1ZV0``
-  Contents:
   ``["G02NSrQfjFXQ7Io09syajA", "constant_attendance_allowance",``
   ``true]``


The combined format for the (Q)EAA issuance is represented below:

.. code-block::

  eyJhbGciOiAiRVMyNTYiLCAidHlwIjogImRjK3NkLWp3dCIsICJraWQiOiAiZDEyNmE2
  YTg1NmY3NzI0NTYwNDg0ZmE5ZGM1OWQxOTUifQ.eyJfc2QiOiBbIkR4LTZoanZyY3hOe
  kYwc2xVNnVrTm16SG9MLVl2Qk4tdEZhMFQ4WC1iWTAiLCAiR0UzU2p5X3pBVDM0Zjh3Y
  TVEVWtWQjBGc2xhU0pSQUFjOEkzbE4xMUZmYyIsICJWUUktUzFtVDFLeGZxMm84Sjlpb
  zd4TU1YMk1JeGFHOU05UGVKVnFyTWNBIiwgIllyYy1zLVdTcjRleEVZdHFERXNtUmw3c
  3BvVmZtQnhpeFAxMmU0c3lxTkUiLCAiYUJWZGZjbnhUMFo1UnJ3ZHhaU1VodVV4ejNnT
  TJ2Y0VaTGVZSWo2MUthcyIsICJvMWNIRzhKYkVFWXYwSGVKSU5ZS2JGTGQtVG5FRFV1T
  npJMVhwelYzMmFVIiwgInMxWEs1ZjJwTTMtYUZUYXVYaG12ZDlweVFUSjZGTVVoYy1KW
  GZIcnhoTGsiLCAielZkZ2hjbUNsTVZXbFVnR3NHcFNrQ1BrRUhaNHU5b1dqMVNsSUJsQ
  2MxbyJdLCAiZXhwIjogMTg4MzAwMDAwMCwgImlzcyI6ICJodHRwczovL2lzc3Vlci5le
  GFtcGxlLm9yZyIsICJzdWIiOiAiTnpiTHNYaDh1RENjZDdub1dYRlpBZkhreFpzUkdDO
  VhzIiwgImlzc3VpbmdfYXV0aG9yaXR5IjogIklzdGl0dXRvIFBvbGlncmFmaWNvIGUgW
  mVjY2EgZGVsbG8gU3RhdG8iLCAiaXNzdWluZ19jb3VudHJ5IjogIklUIiwgInN0YXR1c
  yI6IHsic3RhdHVzX2Fzc2VydGlvbiI6IHsiY3JlZGVudGlhbF9oYXNoX2FsZyI6ICJza
  GEtMjU2In19LCAidmN0IjogImh0dHBzOi8vaXNzdWVyLmV4YW1wbGUub3JnL3YxLjAvZ
  GlzYWJpbGl0eWNhcmQiLCAidmN0I2ludGVncml0eSI6ICIyZTQwYmNkNjc5OTAwODA4N
  WZmYjFhMWYzNTE3ZWZlZTMzNTI5OGZkOTc2YjNlNjU1YmZiM2Y0ZWFhMTFkMTcxIiwgI
  l9zZF9hbGciOiAic2hhLTI1NiIsICJjbmYiOiB7Imp3ayI6IHsia3R5IjogIkVDIiwgI
  mNydiI6ICJQLTI1NiIsICJ4IjogIlRDQUVSMTladnUzT0hGNGo0VzR2ZlNWb0hJUDFJT
  GlsRGxzN3ZDZUdlbWMiLCAieSI6ICJaeGppV1diWk1RR0hWV0tWUTRoYlNJaXJzVmZ1Z
  WNDRTZ0NGpUOUYySFpRIn19fQ.L-km4kT5RCMVd9S5ZuVxINxfiSOksgcQNTGb71EhjF
  fkqptx-upFnx3KEHHmGFoyftiT1ScKHBUiWvBj32MAYg~WyIyR0xDNDJzS1F2ZUNmR2Z
  yeU5STjl3IiwgImlhdCIsIDE2ODMwMDAwMDBd~WyJlbHVWNU9nM2dTTklJOEVZbnN4QV
  9BIiwgImRvY3VtZW50X251bWJlciIsICJYWFhYWFhYWFhYIl0~WyI2SWo3dE0tYTVpVl
  BHYm9TNXRtdlZBIiwgImdpdmVuX25hbWUiLCAiTWFyaW8iXQ~WyJlSThaV205UW5LUHB
  OUGVOZW5IZGhRIiwgImZhbWlseV9uYW1lIiwgIlJvc3NpIl0~WyJRZ19PNjR6cUF4ZTQ
  xMmExMDhpcm9BIiwgImJpcnRoX2RhdGUiLCAiMTk4MC0wMS0xMCJd~WyJBSngtMDk1Vl
  BycFR0TjRRTU9xUk9BIiwgImV4cGlyeV9kYXRlIiwgIjIwMjQtMDEtMDEiXQ~WyJQYzM
  zSk0yTGNoY1VfbEhnZ3ZfdWZRIiwgInBlcnNvbmFsX2FkbWluaXN0cmF0aXZlX251bWJ
  lciIsICJYWDAwMDAwWFgiXQ~WyJHMDJOU3JRZmpGWFE3SW8wOXN5YWpBIiwgImNvbnN0
  YW50X2F0dGVuZGFuY2VfYWxsb3dhbmNlIiwgdHJ1ZV0~

MDOC-CBOR
=========

The PID/(Q)EAA MDOC-CBOR data model is based on ISO/IEC 18013-5 standard, initially developed for the mobile driving license (mDL) use case. 
The MDOC data elements MUST be encoded as defined in `RFC 8949 - Concise Binary Object Representation (CBOR) <RFC 8949 - Concise Binary Object Representation (CBOR)>`_.

This data model structures PID/QEAA Credentials into distinct components: document type (**docType**), namespaces (**nameSpaces**), and cryptographic proof. 
The document type identifies the Credential's nature, while namespaces categorize and structure data elements (or attributes, see `Attributes Namespaces`_). 
However the cryptographic proof ensure integrity and authenticity through the Mobile Security Object (MSO).

A PID encoded in MDOC-CBOR format uses the document type set to `eu.europa.ec.eudi.pid.1` as specified in the `EIDAS-ARF`_, following the reverse domain approach defined in the ISO/IEC 18013-5.
National PID attributes are defined within the domestic namespace `eu.europa.ec.eudi.pid.it.1`, whereas mandatory mDL attributes utilize the standard namespace `org.iso.18013.5.1.mDL`.

The MSO serves as the cryptographic proof, securely storing cryptographic digests of attributes within the namespases. 
This allows verifiers to validate disclosed attributes against corresponding **digestID** values without revealing the entire credential.
See `Mobile Security Object`_ for details.

The MDOC-CBOR Credential structure is outlined below and elaborated in the following sections.

.. list-table:: 
    :widths: 20 60 20
    :header-rows: 1

    * - **Parameter**
      - **Description**
      - **Reference**
    * - **nameSpaces** 
      - *json (json object)*. Returned data elements for the namespaces. It MAY be possible to have one or more namespaces. The `nameSpaces` MUST use the same value for the document type. However, it MAY have a domestic namespace to include attributes defined in this implementation profile. The value MUST be set to ``eu.europa.ec.eudi.pid.it.1``.
      - [ISO 18013-5#8.3.2.1.2]
    * - **issuerAuth**
      - *bstr (byte string)*. Contains *Mobile Security Object* (MSO), a COSE Sign1 Document, issued by the Credential Issuer.
      - [ISO 18013-5#9.1.2.4]

Attributes Namespaces
--------------------------------

The **nameSpaces** object contains one or more *IssuerSignedItemBytes* that are encoded using CBOR bitsring 24 tag (#6.24(bstr .cbor), marked with the CBOR Tag 24(<<... >>) and represented in the example using the diagnostic format). It represents the disclosure information for each digest within the `Mobile Security Object` and MUST contain the following attributes:

.. list-table:: 
    :widths: 20 60 20
    :header-rows: 1

    * - **Name**
      - **Encoding**
      - **Description**
    * - **digestID**
      - *integer*
      - Reference value to one of the ``ValueDigests`` provided in the *Mobile Security Object* (`issuerAuth`).
    * - **random**
      - *bstr (byte string)*
      - Random byte value used as salt for the hash function. This value SHALL be different for each *IssuerSignedItem* and it SHALL have a minimum length of 16 bytes.
    * - **elementIdentifier**
      - *tstr (text string)*
      - Data element identifier.
    * - **elementValue**
      - depends by the value, see the next table.
      - Data element value.

The **elementIdentifier** data that MUST be included in a PID/(Q)EAA are: 

.. list-table:: 
    :widths: 20 60 20
    :header-rows: 1

    * - **Namespace**
      - **Element identifier**
      - **Description**
    * - **eu.europa.ec.eudi.pid.1**
      - **issuance_date**
      - *full-date (CBORTag 1004)*. Date when the PID/(Q)EAA was issued.
    * - **eu.europa.ec.eudi.pid.1**
      - **expiry_date**
      - *full-date (CBORTag 1004)*. Date when the PID/(Q)EAA will expire.
    * - **eu.europa.ec.eudi.pid.1**
      - **issuing_authority**
      - *tstr (text string)*. Name of administrative authority that has issued the PID/(Q)EAA.
    * - **eu.europa.ec.eudi.pid.1**
      - **issuing_country**
      - *tstr (text string)*. Alpha-2 country code as defined in [ISO 3166].


Depending on the Digital Credential type, additional **elementIdentifier** data MAY be added. The PID MUST support the following data:

.. list-table:: 
    :widths: 20 60 20
    :header-rows: 1

    * - **Namespace**
      - **Element identifier**
      - **Description**
    * - **eu.europa.ec.eudi.pid.1**
      - **given_name**
      - *tstr (text string)*. See :ref:`PID Claims fields Section <sec-pid-user-claims>`.
    * - **eu.europa.ec.eudi.pid.1**      
      - **family_name**
      - *tstr (text string)*. See :ref:`PID Claims fields Section <sec-pid-user-claims>`.
    * - **eu.europa.ec.eudi.pid.1**
      - **birth_date**
      - *full-date (CBORTag 1004)*. See :ref:`PID Claims fields Section <sec-pid-user-claims>`.
    * - **eu.europa.ec.eudi.pid.1**
      - **birth_place**
      - *tstr (text string)*. See :ref:`PID Claims fields Section <sec-pid-user-claims>`.
    * - **eu.europa.ec.eudi.pid.1**
      - **nationality**
      - *tstr (text string)*. See :ref:`PID Claims fields Section <sec-pid-user-claims>`.
    * - **eu.europa.ec.eudi.pid.it.1**
      - **personal_administrative_number**
      - *tstr (text string)*. See :ref:`PID Claims fields Section <sec-pid-user-claims>`.


Mobile security Object
--------------------------

The **issuerAuth** represents the `Mobile Security Object` which is a `COSE Sign1 Document` defined in `RFC 9052 - CBOR Object Signing and Encryption (COSE): Structures and Process <https://www.rfc-editor.org/rfc/rfc9052.html>`_. It has the following data structure:

* protected header
* unprotected header
* payload
* signature.

The **protected header** MUST contain the following parameter encoded in CBOR format:

.. list-table:: 
    :widths: 20 60 20
    :header-rows: 1

    * - **Element**
      - **Description**
      - **Reference**
    * - **1**
      - Algorithm used to verify the cryptographic signature of the mdoc Digital Credential (REQUIRED).
      - RFC8152

.. note::
    
    Only the Signature Algorithm MUST be present in the protected headers, other elements SHOULD not be present in the protected header.


The **unprotected header** MUST contain the following parameter:

.. list-table:: 
    :widths: 20 60 20
    :header-rows: 1

    * - **Element**
      - **Description**
      - **Reference**
    * - **4**
      - Unique identifier of the Issuer JWK (OPTIONAL). Required when the issuer of mDOC uses OpenID Federation. 
      - `Trust Model`_
    * - **33**
      - X.509 certificate chain about the Issuer (OPTIONAL). Required for X.509 certificate-based authentication.
      - `RFC 9360 CBOR Object Signing and Encryption (COSE) - Header Parameters for Carrying and Referencing X.509 Certificates`_.

.. note::
    The `x5chain` is included in the unprotected header with the aim to make the Holder able to update the X.509 certificate chain, related to the `Mobile Security Object` issuer, without invalidating the signature.

The **payload** MUST contain the *MobileSecurityObject*, without the `content-type` COSE Sign header parameter and encoded as a *byte string* (bstr) using the *CBOR Tag* 24.

The `MobileSecurityObjectBytes` MUST have the following attributes:

.. list-table:: 
    :widths: 20 60 20
    :header-rows: 1

    * - **Element**
      - **Description**
      - **Reference**
    * - **docType**
      - *tstr (text string)*. Document type. For the PID, the value MUST be set to ``eu.europa.ec.eudi.pid.1.`` For an mDL, the value MUST be ``org.iso.18013-5.1.mDL``.
      - [ISO 18013-5#8.3.2.1.2]
    * - **version**
      - *(tstr)* Version of the data structure being used.
      - [ISO 18013-5#9.1.2.4]
    * - **validityInfo**
      - Object containing issuance and expiration datetimes. It MUST contain the following sub-value:

          * *signed*
          * *validFrom*
          * *validUntil*
      - [ISO 18013-5#9.1.2.4]
    * - **digestAlgorithm**
      - According to the algorithm defined in the protected header.
      - [ISO 18013-5#9.1.2.4]
    * - **valueDigests**
      - Mapped digest by unique id, grouped by namespace.
      - [ISO 18013-5#9.1.2.4]
    * - **deviceKeyInfo**
      - It MUST contain the Wallet Instance's public key containing the following sub-values.

          * *deviceKey* (REQUIRED).
          * *keyAuthorizations* (OPTIONAL).
          * *keyInfo* (OPTIONAL).
      - [ISO 18013-5#9.1.2.4]

.. note::
    The private key related to the public key stored in the `deviceKey` object is used to sign the `DeviceSignedItems` object and proof the possession of the PID during the presentation phase (see the presentation phase with MDOC-CBOR).


MDOC-CBOR Examples
----------------------

A `Diagnostic Notation` of a PID in MDOC-CBOR format is given below:

.. literalinclude:: ../../examples/pid-mdoc-cbor-example.txt
  :language: text

A `Diagnostic Notation` of a mDL in MDOC-CBOR format is given below:

.. literalinclude:: ../../examples/mDL-mdoc-cbor-example.txt
  :language: text


.. _Attributes Namespaces: pid-eaa-data-model.html#attributes-namespaces
.. _Mobile Security Object: pid-eaa-data-model.html#mobile-security-object
.. _RFC 9360 CBOR Object Signing and Encryption (COSE) - Header Parameters for Carrying and Referencing X.509 Certificates: https://datatracker.ietf.org/doc/rfc9360/
.. _Trust Model: trust.html

